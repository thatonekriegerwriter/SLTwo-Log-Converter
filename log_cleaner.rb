
require 'pathname'

def clean_text_old(file, output, settings)
  # Open the file for reading
  unless File.exist?(file)
    puts "File '#{file}' not found in the current directory."
    return
  end
  
  
  
  
  
  
  
  
  if settings[1] == "multi"
  
  cleaned_lines = File.readlines(file).map do |line|
    next if line =~ /\b\(omit\)\b/  
    next if line =~ /\b\(oir\)\b/   
    next if line =~ /\bOOC\b/       
    next if line =~ /\bLOOC\b/      
    line.gsub!(/^\d{2}:\d{2} - /, "") if settings[0]==false
	

    line.gsub!(/said in (Emote): /, "")
	
    line.gsub!(/said in Say:\s*(.*)/) { "says \"#{$1.strip}\"" }
    line.gsub!(/said in (Say): /, "says ")
	
	
    line.gsub!(/ 's/, "'s")



    line.gsub!(/<b>(.*?)<\/b>/, '**\1**') 
    line.gsub!(/<i>(.*?)<\/i>/, '*\1*')   

    line.strip 
  end.compact 

  File.open(output, 'w') { |f| f.puts cleaned_lines }
  else
   cleaned_lines = []
  previous_line = ""
  
  
  
  
  
  File.readlines(file).each_with_index do |line, index|
    next if line =~ /\b\(omit\)\b/  
    next if line =~ /\b\(oir\)\b/   
    next if line =~ /\bOOC\b/       
    next if line =~ /\bLOOC\b/    
    line.gsub!(/^\d{2}:\d{2} - /, "") if settings[0]==false
	
	
	
    if (line.include?("said in Say") || line.include?("said in Emote")) 
      cleaned_lines << previous_line.strip unless previous_line.empty?
	  previous_line = "\n" + line.strip
	 else
	  previous_line += " " + line.strip
    end









    previous_line.gsub!(/said in (Emote): /, "")
	
    previous_line.gsub!(/said in Say:\s*(.*)/) { "says \"#{$1.strip}\"" }
    previous_line.gsub!(/said in (Say): /, "says ")
	
	
    previous_line.gsub!(/ 's/, "'s")
    previous_line.gsub!(/<b>(.*?)<\/b>/, '**\1**') 
    previous_line.gsub!(/<i>(.*?)<\/i>/, '*\1*')   


	
	
	
	
  end


  cleaned_lines << previous_line.strip unless previous_line.empty?






  File.open(output, 'w') { |f| f.puts cleaned_lines.join("\n") } 
  
  end
end



def filesglob(directory_path)
path = Pathname.new(directory_path)
files = []
files = path.children.select { |child| child.file? }
return files
end
def get_log_files(path)
  files = []
 filesglob(path).each do |file|
    files << File.basename(file)

 end
  return files 
end
def clear_console
  system('cls') || system('clear')
end





  clear_console
if !ENV["OCRAN_EXECUTABLE"].nil?
directory = ENV["OCRAN_EXECUTABLE"]
directory = directory.gsub('\\', '/')
directory = directory.sub('/SL2 Log Converter.exe', '')
script_directory= directory

else
script_directory = File.dirname(__FILE__)
end


#settings = "timestamps","lineamt","reformat","OOC","LOOC","Omit","Omit on Repost","Filter"
settings = [false,"multi",true,false,false,false,false,nil]




input_directory = script_directory + "/put_logs_here/"
output_directory = script_directory + "/logs_output/"
file =  ARGV[0] || "latest_chatlog"
file2 =  "cleaned_#{file}.txt"
input_file = File.join(input_directory, file)
output_file = File.join(output_directory, file2)
input_file = File.join(input_directory, "latest_chatlog.txt") if !File.exists?(input_file)
output_file = File.join(output_directory, "cleaned_latest_chatlog.txt") if !File.exists?(output_file)
input_file = "None" if !File.exists?(input_file)
files = get_log_files(input_directory)

def clean_text(file, output, settings)
  unless File.exist?(file)
    puts "File '#{file}' not found in the current directory."
    return
  end

  if settings[1] == "multi"
    process_multi_line(file, output, settings)
  else
    process_single_line(file, output, settings)
  end
end

def process_single_line(file, output, settings)

  cleaned_lines = []
  previous_line = ""

  File.readlines(file).each do |line|
    next if skip_line?(line, settings)
	#character = get_character_name_or_prefix(line)

    if line.include?("said in Say") || line.include?("said in Emote")
      cleaned_lines << previous_line.strip unless previous_line.empty?
      previous_line = "\n" + line.strip
    else
      previous_line += " " + line.strip
    end

    #next if skip_line2?(line, character, settings)
    previous_line = clean_line(previous_line, settings)
  end

  cleaned_lines << previous_line.strip unless previous_line.empty?

  File.open(output, 'w') { |f| f.puts cleaned_lines.join("\n") }
end

def process_multi_line(file, output, settings)

  cleaned_lines = File.readlines(file).map do |line|
    next if skip_line?(line, settings)
	#character = get_character_name_or_prefix(line)
    clean_line(line, settings)
    #next if skip_line2?(line, character, settings)
  end.compact

  File.open(output, 'w') { |f| f.puts cleaned_lines }
end


def skip_line?(line, settings)
  return true if line =~ /\b\(omit\)\b/ && settings[5] == false
  return true if line =~ /\b\(oir\)\b/ && settings[6] == false
  return true if line =~ /\bOOC\b/ && settings[3] == false
  return true if line =~ /\bLOOC\b/ && settings[4] == false
   if !settings[7].nil?
  return true if line =~ /^\d{2}:\d{2} - #{Regexp.escape(settings[7])} said in (Say|Emote)/ 
   end
  return false
end

def get_character_name_or_prefix(line)
  if line.include?("said in Say") || line.include?("said in Emote") || 
     line.include?("said in LOOC") || line.include?("said in OOC")

    parts = line.split("said in", 2)
    
    first = parts.first.strip
    first.gsub!(/^\d{2}:\d{2} - /, "")
	return first
  else
    return nil
  end
end

def skip_line2?(line, character, settings)
  return false
  return false if character.nil?
  nuline = line.gsub!(character, "").strip
  puts nuline
  return true if nuline.empty?
  return true if nuline == "." || nuline == "**"
  return true if nuline.length==1 && nuline.downcase=="a"
  return false
end

def clean_line(line, settings)
  line.gsub!(/^\d{2}:\d{2} - /, "") if settings[0] == false
  if settings[2] == true
  line.gsub!(/said in (Emote): /, "")
  line.gsub!(/said in Say:\s*(.*)/) { "says \"#{$1.strip}\"" }
  line.gsub!(/said in (Say): /, "says ")
  line.gsub!(/ 's/, "'s")
  line.gsub!(/<b>(.*?)<\/b>/, '**\1**')
  line.gsub!(/<i>(.*?)<\/i>/, '*\1*')
  end
  line.strip
end



def looks_like_file_path?(str)
  return str =~ /^(?:[a-zA-Z]:[\\\/]|\/)?[\w\-\s]+(?:[\\\/][\w\-\s]+)*(\.[\w]+)?$/
end
def valid_file_path?(path)
  return File.exist?(path) && File.file?(path) && File.readable?(path)
end



def log_file_display(filelist)

puts "\n\nLog List:\n"
puts "========================================================================================"
if filelist.length>0
highestnum = 0
filelist.each_with_index do |file,index|
puts "#{index+1}. #{file}"
highestnum = index+1
end
puts "#{highestnum+1}. Exit \n \n"

puts "Please type the number of the Log you would like to select: \n"
value = gets.chomp.to_i
name = filelist[value-1]
else
puts "[No Logs Available]"
  sleep(3) # Waits for 2 seconds

end
 return name
end


hasmanuallysetfilename = false
loop do



#settings = "timestamps","lineamt","reformat","OOC","LOOC","Omit","Omit on Repost","Filter"
puts "\n\nSL2 Log Converter - v1 - Loaded Log: #{File.basename(input_file)} - Output Name: #{File.basename(output_file)} \n"
puts "========================================================================================"
puts "Settings:"
puts "reformat: #{settings[2]} - Reform to a more human readable output."
puts "linemode: #{settings[1]} - If multiline posts are compressed to a single line."
puts "filter: #{settings[7]} - Filter Output to posts from a Single Alias." if !settings[7].nil?
puts "filter: None - Filter Output to posts from a Single Alias." if settings[7].nil?
puts "OOC: #{settings[3]} - Include OOC content in the Output."
puts "LOOC: #{settings[4]} - Include LOOC content in the Output."
puts "Omit: #{settings[5]} - Include Omitted content in the Output."
puts "OIR: #{settings[6]} - Include posts that are reposted content in the Output."
puts "timestamps: #{settings[0]} - If Timestamps are present on the output."
puts "\n\n"
puts "========================================================================================"
puts "Which mode would you like to use?\n"
puts "1. Name - Set Output Log Name. It will output to 'logs_output'. "
puts "2. Select - Select a Log from 'put_logs_here'."
puts "3. Output - Output Converted Log."
puts "4. Help - Directions on program usage."
puts "Setting - Input a setting name (eg: 'timestamps') to enable/disable."
puts "Drop Log - Drop Log on Program to Load it"
puts "Exit - Type 'exit' to exit.\n\n"






puts "Please enter an option: \n"
selected_mode = gets.chomp


 if selected_mode == "1" || selected_mode.downcase == "name"
    puts "Please enter a name: \n"
      name = gets.chomp
    output_file = File.join(output_directory, "#{name}.txt")
     hasmanuallysetfilename = true
  puts "\nOutput Log name set to: #{File.basename(output_file)}."
  sleep(5) # Waits for 2 seconds
  clear_console
 elsif selected_mode == "2" || selected_mode.downcase == "select"
  clear_console
  files = get_log_files(input_directory)
  name = log_file_display(files)
  clear_console
  if !name.nil?
   input_file = File.join(input_directory, name)
   if hasmanuallysetfilename==false
    output_file = File.join(output_directory, "cleaned_#{name}")
    puts "\nOutput Log name set to: #{File.basename(output_file)}."
   end
  end
 elsif selected_mode == "3" || selected_mode.downcase == "output"
  if input_file != "None"
  clear_console
  clean_text(input_file, output_file, settings)
  puts "Conversation saved to: '#{output_file}'"
  else
  puts "\nNo valid log found."
  
  end
  sleep(2) # Waits for 2 seconds
  clear_console
 elsif selected_mode == "4" || selected_mode.downcase == "help"
  clear_console
  puts "HELP:"
  puts "==================================================================================================="
  puts "\nThe Program will automatically load a file named 'latest_chatlog.txt' from the Program directory as it's target file."
  puts "You may also provide a file as a command prompt argument, or drag a file onto the program to be loaded."
  puts "It will automatically output the file as 'cleaned_<file_name>'.txt, which will only contain the conversations contained in the log.\n\n"
  sleep(2) # Waits for 2 seconds
  
  
#settings = "timestamps","lineamt","reformat","OOC","LOOC","Omit","Omit on Repost","Filter"
  
 elsif selected_mode.downcase == "reformat" || selected_mode.downcase == "reformatting"
   settings[2] = !settings[2]
  puts "The output will reformat.\n\n" if settings[2]==true
  puts "The output will not reformat.\n\n" if settings[2]==false
  sleep(2) # Waits for 2 seconds
  clear_console
 elsif selected_mode.downcase == "ooc" || selected_mode.downcase == "ooc"
   settings[3] = !settings[3]
  puts "The output will contain OOC content.\n\n" if settings[3]==true
  puts "The output will not contain OOC content.\n\n" if settings[3]==false
  sleep(2) # Waits for 2 seconds
  clear_console
 elsif selected_mode.downcase == "looc" || selected_mode.downcase == "looc"
   settings[4] = !settings[4]
  puts "The output will contain LOOC content.\n\n" if settings[4]==true
  puts "The output will not contain LOOC content.\n\n" if settings[4]==false
  sleep(2) # Waits for 2 seconds
  clear_console
 elsif selected_mode.downcase == "omit"
   settings[5] = !settings[5]
  puts "The output will contain omitted content.\n\n" if settings[5]==true
  puts "The output will not contain omitted content.\n\n" if settings[5]==false
  sleep(2) # Waits for 2 seconds
  clear_console
 elsif selected_mode.downcase == "oir" || selected_mode.downcase == "omit on repost" || selected_mode.downcase == "omitonrepost" || selected_mode.downcase == "repost" || selected_mode.downcase == "reposted"
   settings[6] = !settings[6]
  puts "The output will contain reposted content.\n\n" if settings[6]==true
  puts "The output will not contain reposted content.\n\n" if settings[6]==false
  sleep(2) # Waits for 2 seconds
  clear_console
 elsif selected_mode.downcase == "filter"
    puts "Please enter an alias: \n"
      name = gets.chomp
	  if !name.empty?
	   if name.downcase=="none"||name.downcase=="erase"
	  settings[7]=nil
      puts "\nFilter removed."
	   else
	  settings[7]=name
      puts "\nFilter set to #{settings[7]}."
	   end
	 else
	  settings[7]=nil
      puts "\nFilter removed."
	 end
  sleep(5) # Waits for 2 seconds
  clear_console
 
 
 elsif selected_mode.downcase == "timestamps" || selected_mode.downcase == "timestamp"
   settings[0] = !settings[0]
  puts "The output will contain timestamps.\n\n" if settings[0]==true
  puts "The output will not contain timestamps.\n\n" if settings[0]==false
  sleep(5) # Waits for 2 seconds
  clear_console
 elsif selected_mode.downcase == "linemode" || selected_mode.downcase == "linemodes"
  if settings[1] == "multi"
   settings[1] = "single" 
  else
   settings[1] = "multi" 
  end
  puts "The output will preserve newlines.\n\n" if settings[1] == "multi"
  puts "The output will have messages all on one line.\n\n" if settings[1] == "single"
  sleep(5) # Waits for 2 seconds
  clear_console
 elsif selected_mode.downcase == "exit"
   break
 elsif looks_like_file_path?(selected_mode)!=0
    temp_file = selected_mode.gsub(/^"(.*)"$/, '\1')
    if valid_file_path?(temp_file)
     clear_console
    input_file = temp_file
    output_file = File.join(output_directory, "cleaned_#{File.basename(input_file)}") if hasmanuallysetfilename==false
	 else
	  puts "This is not a valid file path"
  sleep(3) # Waits for 2 seconds
	end
 else
     clear_console
    puts "Invalid selection. Please enter a number, setting, provide a file for loading, or exit."
  sleep(3) # Waits for 2 seconds
 
  clear_console
 end





end

