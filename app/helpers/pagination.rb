##

module Pagination
  # Foundation pagination with Font Awesome icons
  class PaginationRenderer < WillPaginate::ActionView::LinkRenderer
    protected

      def gap
        tag :li, link(super, '#'), class: 'unavailable'
      end

      def page_number(page)
        tag :li, link(page, page, rel: rel_value(page)),
            class: ('current' if page == current_page)
      end

      def previous_or_next_page(page, _text, classname)
        tag :li, link('<i class="fa fa-arrow-circle-' +
            (classname == 'previous_page' ? 'left' : 'right') +
            '"></i>', page || '#')
      end

      def html_container(html)
        tag(:ul, html, container_attributes)
      end

      def gap
        tag :li, '<a>...</a>'
      end
  end
end
