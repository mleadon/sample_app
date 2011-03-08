module ApplicationHelper

  # Return a title on a per-page basis.
  def title
    base_title = "Tweet Post"
    if @title.nil?
      base_title
    else
      "#{base_title} | #{@title}"
    end
  end
  def cirmLogo
    return image_tag("hoodie.jpg", :alt => "Sample App", :class => "round", :width => "100") 
  end
  def tweetPostLogo
    return image_tag("TweetPostLogo.gif", :alt => "Tweet Post", :class => "round", :width => "100") 
  end
end

