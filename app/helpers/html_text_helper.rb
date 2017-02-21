##

# helper functions to convert html mail to text mail and back
module HtmlTextHelper
  def strip_inline_style(content)
    # strip inline style tags completely
    content.to_s
        .gsub(/<style[^>]*>[^<]*<\/style>/, '')
        .gsub(/<!--[^>]*-->/, '')
  end

  def match_values_inside_brackets_and_replace_with_variable_assignments(content, options={})
    # grab everything between the brackets
    matches = content.to_enum(:scan, /(?<=\[)([^\]]+)(?=\])/).map {$&}
    # replace the brackets with options
    matches.each do |match|
      variable = options[match.to_sym]
      content = content.gsub(/\[(#{match}?)\]/, variable) if variable
    end
    # return content
    content
  end

  def html_to_text(content)
    content = sanitize_html(content).gsub(%r{(<br ?/?>|</p>)}, "\n")
    # to_str for Rails #12672
    content = CGI.unescapeHTML(sanitize(content, tags: []).to_str)
    word_wrap(content, line_width: 72)
  end

  def text_to_html(content)
    CGI.escapeHTML(content).gsub("\n", '<br />')
  end

  def sanitize_html(content, attachments = {})
    result = content

    attachments.each do |content_id,url|
      result.gsub!(/src="cid:#{content_id}"/, "src=\"#{url}\"")
    end

    result = sanitize(
        strip_inline_style(result),
        tags:       %w( a b br code div em i img li ol p pre table td tfoot
                        thead tr span strong ul font ),
        attributes: %w( src href style color )
    )

    result.html_safe
  end

  def wrap_and_quote(content)
    content = html_to_text(content)
    content = content.gsub(/^.*\n>.*$/, '') # strip off last line before older quotes
    content = content.gsub(/^>.*$/, '') # strip off older quotes
    content = word_wrap(content.strip, line_width: 72)
    content.gsub(/^/, '> ')
  end
end
