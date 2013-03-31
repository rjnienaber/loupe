class ConsoleFormatter
  def format(file_path, check_results)
    formatted_path = File.join(File.basename(File.dirname(file_path)), File.basename(file_path))

    return "No vulnerable gems found in #{formatted_path}" if check_results.empty?

    message = [formatted_path]
    check_results.keys.sort.each do |version|
      message << "  #{version}"
      check_results[version].each do |advisory|
        message << "    cve: #{advisory.cve}, #{advisory.url}"
      end
    end
    message << ''
    message.join("\n")
  end
end