require 'zlib'
require 'base64'
require 'rexml/document'
include REXML

class Proxy < Hash
  def method_missing(m,*a)
    if m.to_s =~ /=$/
      self[$`] = a[0]
    elsif a.empty?
      self[m.to_s]
    else
      raise NoMethodError, "#{m}"
    end
  end
end

def parse(f)
  doc = Document.new(File.read(f)).children.detect {|d| d.class == REXML::Element }
  doNode(doc)
end

def doNode(node)
  p = Proxy.new
  node.each_child do |c|
    n = c.name.downcase
    if p.has_key?(n)
      if !p[n].is_a? Array
        p[n] = [p[n]]
      end
      if c.has_elements?
        p[n] << doNode(c)
      else
        p[n] << c.text
      end
    else
      if c.has_elements?
        p[n] = doNode(c)
      else
        p[n] = c.text
      end
    end
  end
  return p
end

def gen(root,file)
  d = parse(file)
  root << d
end

def dodir(dir)
  Dir.glob("#{dir}/*.xml").each do |f|
    print "Slurping #{f}..."
    yield f
    puts "done."
  end
end

def run(datadir, filename, app_type)
  root = []
  dodir(datadir) do |f|
    gen(root,f)
  end

  if( !(app_type.nil?) && ( (app_type == 'pre_app') || (app_type == 'preapp') || (app_type == 'preapps') ) )
    # We don't have application_number for pre-apps, so we sort by PI last name
    # root = root.sort_by { |a| [a.primaryinvestigator.last_name.downcase, a.primaryinvestigator.first_name.downcase] }
    root = root.sort_by { |a| [a.principal_investigator.last_name.downcase, a.principal_investigator.first_name.downcase, a.principal_investigator.middle_name] }
    # In some cases, we have application number as applicationnumber rather than
    # application_number; ex. RBEs
  elsif (app_type == 'loi' || app_type == 'lois')
    root = root.sort_by do |a|
      ln = a.primary_investigator.last_name.downcase unless a.primary_investigator.last_name.nil?
      fn = a.primary_investigator.first_name.downcase unless a.primary_investigator.first_name.nil?
      mn = a.primary_investigator.middle_name.downcase unless a.primary_investigator.middle_name.nil?
      [ln, fn, mn]
    end
  elsif (app_type == 'pr_checklist' || app_type == 'checklist')
    root = root.sort_by { |a| [a.grant_information.grant_number] }
  elsif (app_type == 'rbe' || app_type == 'rbes')
    root = root.sort_by {|a| [a.applicant_info.last_name, a.applicant_info.first_name]}
    # root = root.sort_by {|a| [a.applicantlastname, a.applicantfirstname]}
  elsif (root.first.applicationnumber) 
    root = root.sort {|a,b| a.applicationnumber <=> b.applicationnumber}
    # In some cases, we have project_info directly as its own node rather than as
    # part of project_info
  elsif ( (root.first.project_info.nil?) || (root.first.project_info.blank?) )
    root = root.sort {|a,b| a.application_number <=> b.application_number}
  else
    root = root.sort {|a,b| a.project_info.application_number <=> b.project_info.application_number}
  end

	save(filename,root)
end

def save(filename,root)
  docs = Base64.encode64(Zlib::Deflate.deflate(Marshal.dump(root)))
  template = <<'XXX_EOF_XXX'
require 'base64'
require 'zlib'

class Proxy < Hash
  def method_missing(m,*a)
    if m.to_s =~ /=$/
      self[$`] = a[0]
    elsif a.empty?
      self[m.to_s]
    else
      raise NoMethodError, "#{m}"
    end
  end
end

def data()
  data = <<EOF
XXX_EOF_XXX
  file = File.new(filename,"w")
  file.write(template)
  file.write(docs)
  file.write("EOF\n\tMarshal.load(Zlib::Inflate.inflate(Base64.decode64(data)))\nend\n")
  file.close
end
