##

# helpers used system wide
module ApplicationHelper
  def active_elem_if(elem, condition, attributes = {}, &block)
    if condition
      # define class as empty string when no class given
      attributes[:class] ||= ''
      # add 'active' class
      attributes[:class] += ' active'
    end

    # return the content tag with possible active class
    content_tag(elem, attributes, &block)
  end

  # change the default link renderer for will_paginate
  def will_paginate(collection_or_options = nil, options = {})
    if collection_or_options.is_a? Hash
      options, collection_or_options = collection_or_options, nil
    end
    unless options[:renderer]
      options = options.merge renderer: Pagination::PaginationRenderer
    end
    super(*[collection_or_options, options].compact)
  end

  def tabindex
    @tabindex ||= 0
    @tabindex += 1
  end

end
