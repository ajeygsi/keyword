require 'rubygems'
require 'hpricot'
require "xmlrpc/client"

module KeywordExtractor
  def self.generate_kea_tags(options = {})
#    file_name = "kea/testdocs/en/test/input#{Time.now.to_i}"
#    f = File.open("#{file_name}.txt", 'w')
#    f.write(remove_stopwords(options[:text]))
#    f.close
#
#    system "sh setpath.sh #{RAILS_ROOT}/kea #{options[:model]}"
#
#    kea_keywords = []
#    keyfile = File.open("#{file_name}.key", 'r')
#    kea_keywords = keyfile.readlines.map(&:strip)
#    keyfile.close
#    FileUtils.rm "#{file_name}.txt", :force => true
#    FileUtils.rm "#{file_name}.key", :force => true
#    return kea_keywords
    server = XMLRPC::Client.new( "localhost", '/', 8090)

    return server.call("kea.extractKeyphrases", options[:text], 20)
  end
  

  def self.get_query_tokens(query, unique = false)
    kea_keywords = PatentAbstract.generate_kea_tags(:text => query)
    yte_keywords = PatentAbstract.generate_yte_tags(:context => query)      
    keywords = PatentInfo.merge_keywords(yte_keywords, kea_keywords) 
    keywords_tokens = keywords.collect{|keyword| keyword.split.collect {|word| word.downcase}}.flatten
    query_tokens = query.split.reject{|word| !keywords_tokens.include?(word.downcase.gsub(/[.,;]$/, ''))}.collect{|word| word.downcase.gsub(/[.,;]$/, '')}
    query_tokens = query_tokens.uniq if unique
    return query_tokens
  end

  def self.remove_dups(keywords)
    keywords ||= []
    keywords.reject  {|keyword| keywords.select{|x| x.downcase.include?(keyword.downcase)}.size > 1  }
  end

  def self.remove_stopwords(query)
    query ||= ''
    tokens = query.downcase.split(' ')
    STOP_WORDS.each do |stopword|
      tokens.delete(stopword.downcase.strip)
    end

    Exclusion.get_exclusion_list.each do |exclusion|
      tokens.delete(exclusion.downcase.strip)
    end
    tokens.join(' ') # Return the final query
  end

  def self.merge_keywords(yte_keywords, kea_keywords)
    results = {}
    keywords = kea_keywords + yte_keywords
    # Normalize using stemming
    keywords.each  { |keyword| results[keyword.downcase.stem_porter] = keyword }

    # Merge the keywords into single array and avoid dups using Porter's stemming
    loop_size = [yte_keywords.size, kea_keywords.size].max
    output_size = 0
    output = []
    (0..loop_size).each do |i|
      if yte_keywords[i]
        output[output_size] = results[yte_keywords[i].downcase.stem_porter]
        output_size += 1
      end
      if kea_keywords[i]
        output[output_size] = results[kea_keywords[i].downcase.stem_porter]
        output_size += 1
      end
    end
    output.uniq
  end

  def self.parse_keywords_from_html(text)
    if text.blank?
      return [[], true]
    end
    text = Hpricot(text.downcase)
    final_keywords = []
    index = -1
    start_stack = 0
    text.search("//span").each  do |span|
      if span.classes.include?("start")
        start_stack += 1
        if start_stack == 1
          index += 1
          final_keywords[index] = ""
        end
      end
      
      if span.classes.include?("selected")
        char = span.html
        char = ' ' if char == '&nbsp;'
        final_keywords[index] += char
      end

      if span.classes.include?("end")
        start_stack -= 1
      end
    end
    return [final_keywords.collect(&:strip).uniq, start_stack == 0]
  end

  def self.split_found_and_related_keywords(input_text, keywords)
    input_text = input_text.downcase
    keywords ||= []
    found_keywords = []
    related_keywords = []
    keywords.each do |keyword|
      keyword = keyword.downcase
      present = input_text.include? keyword
      if present
        found_keywords << keyword
      else
        related_keywords << keyword
      end
    end
    [found_keywords, related_keywords]
  end
end
