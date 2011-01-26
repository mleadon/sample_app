module ApplicationHelper

  # Return a title on a per-page basis.
  def title
    base_title = "Michael's Sample App"
    if @title.nil?
      base_title
    else
      "#{base_title} | #{@title}"
    end
  end
  def cirmLogo
    return image_tag("hoodie.jpg", :alt => "Sample App", :class => "round", :width => "100") 
  end
end

