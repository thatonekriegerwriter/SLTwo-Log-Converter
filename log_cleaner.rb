
require 'fox16'
require 'pathname'

include Fox
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
    next if File.basename(file) == "FILE"
    files << File.basename(file)

 end
  return files 
end
def clear_console
  system('cls') || system('clear')
end

def nil_or_empty?(string)
  return string.nil? || !string.is_a?(String) || string.size == 0
end




if !ENV["OCRAN_EXECUTABLE"].nil?
directory = ENV["OCRAN_EXECUTABLE"]
directory = directory.gsub('\\', '/')
directory = directory.sub('/SL2 Log Converter.exe', '')
$script_directory= directory

else
$script_directory = File.dirname(__FILE__)
end




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
  return true if line =~ /\b\(repost\)\b/ && settings[6] == false
  return true if line =~ /\bOOC\b/ && settings[3] == false
  return true if line =~ /\bLOOC\b/ && settings[4] == false
   if !nil_or_empty?(settings[7])
  if !line.include?(settings[7])
  return true 
  end
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


class SL2Toolkit < FXMainWindow
  def initialize(app, bot=nil)
    super(app, "Omen's SL2 Toolkit", nil, nil, DECOR_TITLE | DECOR_CLOSE, 0, 0, 840, 800)
    @menu_bar = FXMenuBar.new(self, LAYOUT_SIDE_TOP | LAYOUT_FILL_X)
    help_menu = FXMenuPane.new(self)
    FXMenuTitle.new(@menu_bar, "Help", :popupMenu => help_menu)
#settings = "timestamps","single line","reformat","OOC","LOOC","Omit","Omit on Repost","Filter"
@settings = [false,false,true,false,false,false,false,nil]




@input_directory_original = $script_directory + "/put_logs_here/"
@input_directory = $script_directory + "/put_logs_here/"
@output_directory = $script_directory + "/logs_output/"
@file =  ARGV[0] || "latest_chatlog"
@file2 =  "cleaned_#{@file}.txt"
@input_file = File.join(@input_directory, @file)
@output_file = File.join(@output_directory, @file2)
@input_file = File.join(@input_directory, "latest_chatlog.txt") if !File.exists?(@input_file)
@output_file = File.join(@output_directory, "cleaned_latest_chatlog.txt") if !File.exists?(@output_file)
@input_file = "None" if !File.exists?(@input_file)
@files = get_log_files(@input_directory)
@customname = ""

    status_bar = FXStatusBar.new(self, LAYOUT_SIDE_BOTTOM | LAYOUT_FILL_X)
    tab_book = FXTabBook.new(self, nil, 0, LAYOUT_FILL_X | LAYOUT_FILL_Y)
    tab_book.connect(SEL_COMMAND) do |sender, sel, data|
      case tab_book.current
      when 0
        # Execute code specific to Tab 1
      when 1
        # Execute code specific to Tab 2
      when 2
        # Execute code specific to Tab 2
      when 3
        # Execute code specific to Tab 2
      when 4
        # Execute code specific to Tab 2
      end
    end
	drawObjects(tab_book)
	drawTopMenu(tab_book,help_menu)
    show(PLACEMENT_SCREEN)
    #self.connect(SEL_CLOSE, method(:on_close)) 
 end




def drawObjects(tab_book)
    drawBasicInfo(tab_book)


end
 def drawTopMenu(tab_book,help_menu)
 	FXMenuCommand.new(help_menu, "&Help").connect(SEL_COMMAND) do

    end
 
 end


 def drawMenu(tab_book,file_menu)
	FXMenuCommand.new(file_menu, "&Load Log\tCtl-L\tLoad Log from a file").connect(SEL_COMMAND) do
      load_data_internal(tab_book)
    end
	
	FXMenuCommand.new(file_menu, "&Save Log\tCtl-R\tSave Log").connect(SEL_COMMAND) do
   	  save_to_file(@output_file)
	end

	FXMenuCommand.new(file_menu, "&Save Log As\tCtl-S\tSave data under another name").connect(SEL_COMMAND) do
      save_data
    end

	FXMenuCommand.new(file_menu, "Exit").connect(SEL_COMMAND) do
      app.exit
    end






 end
def save_to_file(filename)
  if @text_box.text.empty?
    FXMessageBox.error(self, MBOX_OK, "Error", "There is nothing to save!")
    return 
  end
  File.open(filename, 'w') { |f| f.puts @text_box.text }
  FXMessageBox.information(self, MBOX_OK, "File Saved", "Saved to... #{File.basename(@output_file)}")
end
def save_data
  if @text_box.text.empty?
    FXMessageBox.error(self, MBOX_OK, "Error", "There is nothing to save!")
    return 
  end
  dialog = FXFileDialog.new(self, "Save Data")
  dialog.selectMode = SELECTFILE_ANY
  dialog.patternList = ["Text Files (*.txt)", "All Files (*)"]
  dialog.directory = @output_directory
  if dialog.execute != 0
    filename = dialog.filename
    save_to_file(filename)
  end
end
def load_data_internal(tab_book)
    dialog = FXFileDialog.new(self, "Load Data")
    dialog.selectMode = SELECTFILE_EXISTING
    dialog.patternList = ["Text Files (*.txt)", "All Files (*)"]
	dialog.directory = @input_directory
    if dialog.execute != 0
      file_path = dialog.filename
      begin
        # Read the file's content and set it to the text box
		
        set_message_data(file_path)
	    if nil_or_empty?(@customname)
        @file2 =  "cleaned_#{File.basename(file_path)}"
        @output_file = File.join(@output_directory, @file2)
        @namelabel2.text = "Output Name: #{File.basename(@output_file)}"
		end
      rescue => e
        FXMessageBox.error(self, MBOX_OK, "Error", "Failed to load file: #{e.message}")
      end
    end
  end

  def set_message_data(file_path)
  
        file_content = File.read(file_path)
		@file = File.basename(file_path) 
		nufilepath = file_path.gsub(@file, "")
		if nufilepath!=@input_directory
		 @input_directory=nufilepath
		end
      @input_file = File.join(@input_directory, @file)
        @text_box.text = file_content
        @namelabel.text = "Loaded File: #{@file}"
  end

  def drawBasicInfo(tab_book)
  
    # Create the first page
    page1 = FXTabItem.new(tab_book, "Log Converter")
    # Create a vertical layout for page 1
    main_frame = FXVerticalFrame.new(tab_book, LAYOUT_FILL_X | LAYOUT_FILL_Y, padding: 10)

    menu_bar = FXMenuBar.new(main_frame, LAYOUT_SIDE_TOP | LAYOUT_FILL_X)
    file_menu = FXMenuPane.new(main_frame)
    FXHorizontalSeparator.new(main_frame)
    FXMenuTitle.new(menu_bar, "File", :popupMenu => file_menu)
	drawMenu(tab_book,file_menu)
	 name = "None"
	 name = File.basename(@input_file) if File.exists?(@input_file)
    spacer_frame1 = FXHorizontalFrame.new(main_frame, opts: LAYOUT_FILL_X | LAYOUT_CENTER_Y)
    FXLabel.new(spacer_frame1, "                   ")
    @namelabel = FXLabel.new(spacer_frame1, "Loaded Log: #{name}", opts: LAYOUT_CENTER_Y)
    @reloadbutton = FXButton.new(spacer_frame1, "Reload\tgejo\tReloads currently displayed text", nil, nil, 0, opts: BUTTON_NORMAL | LAYOUT_CENTER_Y | LAYOUT_FIX_WIDTH, width: 100)
    FXLabel.new(spacer_frame1, "                           ")
    @namelabel2 = FXLabel.new(spacer_frame1, "Output Name: #{File.basename(@output_file)}", opts: LAYOUT_CENTER_Y)
    @exportbutton = FXButton.new(spacer_frame1, "Export\tgejo\tExports log under given name", nil, nil, 0, opts: BUTTON_NORMAL | LAYOUT_CENTER_Y | LAYOUT_FIX_WIDTH, width: 100)
    FXHorizontalSeparator.new(main_frame)

    spacer_frame = FXHorizontalFrame.new(main_frame, opts: LAYOUT_FILL_X | LAYOUT_CENTER_Y, padding: 10)

    # Left checkbox
    left_frame = FXVerticalFrame.new(spacer_frame, opts: LAYOUT_FIX_WIDTH, width: 150)
    FXLabel.new(left_frame, "Load File:\tgejo\tA list of a files in the default log folder.")
    FXHorizontalSeparator.new(left_frame)
    @handedness_dropdown = FXComboBox.new(left_frame, 20)
    @handedness_dropdown.numVisible = 5
    FXLabel.new(left_frame, "Filter:\tgejo\tA filter to only show in your log posts with what is typed in this box.")
    FXHorizontalSeparator.new(left_frame)
    @prefix_textfield = FXTextField.new(left_frame, 20)
    FXLabel.new(left_frame, "Custom Name:\tgejo\tA custom output name for your Log.")
    FXHorizontalSeparator.new(left_frame)
    @cname_textfield = FXTextField.new(left_frame, 20)
    #FXLabel.new(spacer_frame, "              ")


    # Non-editable text box
    @text_box = FXText.new(spacer_frame, opts: TEXT_READONLY | LAYOUT_FIX_WIDTH | LAYOUT_FIX_HEIGHT)
    @text_box.text = ""
    @text_box.width = 500
    @text_box.height = 500
	if File.exists?(@input_file)
    set_message_data(@input_file) 
	add_item_to_combo_box(@handedness_dropdown,File.basename(@input_file))
    end
	@files.each_with_index do |file,index|
	add_item_to_combo_box(@handedness_dropdown,File.basename(file))
	if !File.exists?(@input_file)
      @input_file = File.join(@input_directory, file)
    set_message_data(@input_file) 
	
	end
	end
    # Right checkbox
	
	
	
	
	
    right_frame = FXVerticalFrame.new(spacer_frame, opts: LAYOUT_FIX_WIDTH, width: 150)
    spacer_frame30 = FXHorizontalFrame.new(right_frame, opts: LAYOUT_FILL_X | LAYOUT_CENTER_Y)
    FXHorizontalSeparator.new(right_frame)
    spacer_frame3 = FXHorizontalFrame.new(right_frame, opts: LAYOUT_FILL_X | LAYOUT_CENTER_Y)
    spacer_frame31 = FXHorizontalFrame.new(right_frame, opts: LAYOUT_FILL_X | LAYOUT_CENTER_Y)
    spacer_frame32 = FXHorizontalFrame.new(right_frame, opts: LAYOUT_FILL_X | LAYOUT_CENTER_Y)
    spacer_frame33 = FXHorizontalFrame.new(right_frame, opts: LAYOUT_FILL_X | LAYOUT_CENTER_Y)
    spacer_frame34 = FXHorizontalFrame.new(right_frame, opts: LAYOUT_FILL_X | LAYOUT_CENTER_Y)
    spacer_frame35 = FXHorizontalFrame.new(right_frame, opts: LAYOUT_FILL_X | LAYOUT_CENTER_Y)
    spacer_frame36 = FXHorizontalFrame.new(right_frame, opts: LAYOUT_FILL_X | LAYOUT_CENTER_Y)
    FXLabel.new(spacer_frame30, "Settings:\tgejo\tGeneral Settings for Log output.")
    FXLabel.new(spacer_frame3, "Reformat:\tgejo\tIf checked reformats your log to be human readable.")
    @reformat = FXCheckButton.new(spacer_frame3, "\tgejo\tIf checked reformats your log to be human readable.")
    FXLabel.new(spacer_frame31, "Timestamps:\tgejo\tIf checked, includes timestamps in your log.")
    @timestamps = FXCheckButton.new(spacer_frame31, "\tgejo\tIf checked, includes timestamps in your log.")
    FXLabel.new(spacer_frame32, "Single Line:\tgejo\tIf checked, makes multiline messages one line.")
    @single = FXCheckButton.new(spacer_frame32, "\tgejo\tIf checked, makes multiline messages one line.")
    FXLabel.new(spacer_frame33, "OOC:\tgejo\tIf checked, includes OOC messages in your Log.")
    @ooc = FXCheckButton.new(spacer_frame33, "\tgejo\tIf checked, includes OOC messages in your Log.")
    FXLabel.new(spacer_frame34, "LOOC:\tgejo\tIf checked, includes LOOC messages in your Log.")
    @looc = FXCheckButton.new(spacer_frame34, "\tgejo\tIf checked, includes LOOC messages in your Log.")
    FXLabel.new(spacer_frame35, "Omit:\tgejo\tIf checked, includes messages marked with (omit) in your Log.")
    @omit = FXCheckButton.new(spacer_frame35, "\tgejo\tIf checked, includes messages marked with (omit) in your Log.")
    FXLabel.new(spacer_frame36, "Omit on Repost:\tgejo\tIf checked, includes messages marked with (oir) or (repost) in your Log.")
    @oir = FXCheckButton.new(spacer_frame36, "\tgejo\tIf checked, includes messages marked with (oir) or (repost) in your Log.")

#settings = "timestamps","single line","reformat","OOC","LOOC","Omit","Omit on Repost","Filter"
#@settings = [false,false,true,false,false,false,false,nil]
    @reformat.setCheck(@settings[2])
    @timestamps.setCheck(@settings[0])
    @single.setCheck(@settings[1])
    @ooc.setCheck(@settings[3])
    @looc.setCheck(@settings[4])
    @omit.setCheck(@settings[5])
    @oir.setCheck(@settings[6])
	@reformat.connect(SEL_COMMAND) do 
       if @reformat.checked?
	    @settings[2]=true
       else
	    @settings[2]=false
       end
	end
	@timestamps.connect(SEL_COMMAND) do 
       if @timestamps.checked?
	    @settings[0]=true
       else
	    @settings[0]=false
       end
	end
	@single.connect(SEL_COMMAND) do 
       if @single.checked?
	    @settings[1]=true
       else
	    @settings[1]=false
       end
	end
	@ooc.connect(SEL_COMMAND) do 
       if @ooc.checked?
	    @settings[3]=true
       else
	    @settings[3]=false
       end
	end
	@looc.connect(SEL_COMMAND) do 
       if @looc.checked?
	    @settings[4]=true
       else
	    @settings[4]=false
       end
	end
	@omit.connect(SEL_COMMAND) do 
       if @omit.checked?
	    @settings[5]=true
       else
	    @settings[5]=false
       end
	end
	@oir.connect(SEL_COMMAND) do 
       if @oir.checked?
	    @settings[6]=true
       else
	    @settings[6]=false
       end
	end

    # Horizontal frame for buttons at the bottom
    button_frame = FXHorizontalFrame.new(main_frame, opts: LAYOUT_CENTER_X | LAYOUT_FILL_X, padding: 10)

    FXLabel.new(button_frame, "                                                         ")
    FXLabel.new(button_frame, "                                                         ")
    @convertbutton = FXButton.new(button_frame, "Convert\tgejo\tConverts text in current Log to new format", nil, nil, 0, opts: BUTTON_NORMAL | LAYOUT_CENTER_Y | LAYOUT_FIX_WIDTH, width: 100)

	
	
	
	
	
	
	
	@handedness_dropdown.connect(SEL_COMMAND) do
       file_path = File.join(@input_directory_original, @handedness_dropdown.getItemText(@handedness_dropdown.currentItem))

	   if @input_directory!=@input_directory_original
	    @input_directory=@input_directory_original
	   end

  if !File.exist?(file_path)
    FXMessageBox.error(self, MBOX_OK, "Error", "Failed to load file: #{@input_file}")
	else
       set_message_data(file_path)
	    if nil_or_empty?(@customname)
        @file2 =  "cleaned_#{@handedness_dropdown.getItemText(@handedness_dropdown.currentItem)}"
        @output_file = File.join(@output_directory, @file2)
        @namelabel2.text = "Output Name: #{File.basename(@output_file)}"
		end
  end
   end
	
	
	@reloadbutton.connect(SEL_COMMAND) do
  if !File.exist?(@input_file)
    FXMessageBox.error(self, MBOX_OK, "Error", "Failed to load file: #{@input_file}")
    else
       set_message_data(@input_file)
	    if nil_or_empty?(@customname)
        @file2 =  "cleaned_#{File.basename(@input_file)}"
        @output_file = File.join(@output_directory, @file2)
        @namelabel2.text = "Output Name: #{File.basename(@output_file)}"
		end
  end
   end
	@convertbutton.connect(SEL_COMMAND) do
	  SLClean(@text_box, @settings)
   end
	@prefix_textfield.connect(SEL_CHANGED) do
	    @settings[7]=@prefix_textfield.text
   end
	@cname_textfield.connect(SEL_CHANGED) do
	    @customname="#{@cname_textfield.text}.txt"
        @output_file = File.join(@output_directory, @customname)
        @namelabel2.text = "Output Name: #{File.basename(@output_file)}"
   end
	@exportbutton.connect(SEL_COMMAND) do
   	  save_to_file(@output_file)
   end




  end
  

  
    def add_item_to_combo_box(combobox,item)
    item_count = combobox.numItems
    item_exists = false

    (0...item_count).each do |i|
      if combobox.getItemText(i) == item
        item_exists = true
        break
      end
    end

    combobox.appendItem(item) unless item_exists
  end

def SLsingleline(textsource, settings)
  full_text = textsource.text

  cleaned_lines = []
  previous_line = ""

  File.readlines(@input_file).each do |line|
    next if skip_line?(line, settings)
	#character = get_character_name_or_prefix(line)

    if line.include?("said in Say") || line.include?("said in Emote") || line.include?("said in LOOC") || line.include?("said in OOC")
      cleaned_lines << previous_line.strip unless previous_line.empty?
      previous_line = "\n" + line.strip
    else
      previous_line += " " + line.strip
    end

    #next if skip_line2?(line, character, settings)
    previous_line = clean_line(previous_line, settings)
  end

  cleaned_lines << previous_line.strip unless previous_line.empty?

  textsource.text = cleaned_lines.join("\n")
  
  
end




def SLmultiline(textsource, settings)
  full_text = textsource.text
  lines = full_text.split("\n")


  cleaned_lines = File.readlines(@input_file).map do |line|
    next if skip_line?(line, settings)
	#character = get_character_name_or_prefix(line)
    clean_line(line, settings)
    #next if skip_line2?(line, character, settings)
  end.compact

    textsource.text = cleaned_lines.join("\n")

end

def SLClean(textsource, settings)
  if @text_box.text.empty?
    FXMessageBox.error(self, MBOX_OK, "Error", "There is nothing to convert!")
    return 
  end
  unless File.exist?(@input_file)
    FXMessageBox.error(self, MBOX_OK, "Error", "Failed to load file: #{@input_file}")
    return
  end
  if settings[1] == false
    SLmultiline(textsource, settings)
  else
    SLsingleline(textsource, settings)
  end
 
end

def on_close(sender, sel, event)
  savedate
$time_thread.exit
$alyra_thread.exit
$node_thread.exit
$gui_thread.exit
  end
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

  FXApp.new do |app|
    app.normalFont = FXFont.new(app, "Segoe UI", 9, FONTWEIGHT_NORMAL)
    main_window = SL2Toolkit.new(app)
	app.create
    app.run
  end
if false
#settings = "timestamps","lineamt","reformat","OOC","LOOC","Omit","Omit on Repost","Filter"
settings = [false,"multi",true,false,false,false,false,nil]




input_directory = $script_directory + "/put_logs_here/"
output_directory = $script_directory + "/logs_output/"
file =  ARGV[0] || "latest_chatlog"
file2 =  "cleaned_#{file}.txt"
input_file = File.join(input_directory, file)
output_file = File.join(output_directory, file2)
input_file = File.join(input_directory, "latest_chatlog.txt") if !File.exists?(input_file)
output_file = File.join(output_directory, "cleaned_latest_chatlog.txt") if !File.exists?(output_file)
input_file = "None" if !File.exists?(input_file)
files = get_log_files(input_directory)

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
end





# Create the FXApp instance
