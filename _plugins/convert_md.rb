# Convert the links that point to a 'README.md' to 'index.html'
Jekyll::Hooks.register :pages, :post_render do |doc|
  doc.output = doc.output.gsub(/(href="\.\/[^.]*)README\.md?(#(.*))?"/, '\1index.html\2"')
end

# Convert the links that ends with '.md' to '.html'
Jekyll::Hooks.register :pages, :post_render do |doc|
  doc.output = doc.output.gsub(/(href="\.\/[^.]*)\.md?(#(.*))?"/, '\1.html\2"')
end
