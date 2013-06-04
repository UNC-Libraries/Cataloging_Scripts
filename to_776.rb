require 'setup'

timer = Timer.new
timer.time("Done!") do
  
  reader = MARC::Reader.new(ARGV[0])
  writer = MARC::Writer.new("#{ARGV[0]}_ch.mrc")
  
  main_entry_errors = []
  
  puts "\n\n-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
  puts "776 field"
  puts "-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
  if agree("Create new 776 field?", true)
    create_776 = true
  else
    create_776 = false
  end #if agree("Create new 776 field?", true)
  
  if agree("Change 776$c to $i?", true)
    change_c_to_i = true
    if agree("Change value of $i?", true)
      change_i_value = true
      i_value = ask("Enter new $i value.").chomp
    end #if agree("Should 020$a be moved to 776?", true)
  else
    change_c_to_i = false
    if agree("Insert new $i?", true)
      new_i = true
      i_value = ask("Enter new $i value.").chomp
    else
      new_i = false
      if agree("Change $c value?", true)
        change_c_value = true
        c_value = ask("Enter new $c value.").chomp
      end #if agree ("Change $c value?", true)
    end #if agree("Should 020$a be moved to 776?", true)
  end #if agree("Should 020$a be moved to 776?", true)
  
  puts "\n\n-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
  puts "010 field"
  puts "-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
  if agree("Should 010$a be moved to 776?", true)
    move_010_a = true
  else
    move_010_a = false
  end #if agree("Should 020$a be moved to 776?", true)
  
  
  puts "\n\n-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
  puts "020 field"
  puts "-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
  if agree("Should 020$a be copied to 776?", true)
    move_020_a = true
  else
    move_020_a = false
  end #if agree("Should 020$a be moved to 776?", true)
  
  if agree("Should 020$z be copied to 776?", true)
    copy_020_z = true
  else
    copy_020_z = false
  end #if agree("Should 020$z be copied to 776?", true)
  
  puts "\n\n-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
  puts "024 field"
  puts "-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
  if agree("Should 024$a be moved to 776?", true)
    move_024_a = true
  else
    move_024_a = false
  end #if agree("Should 020$a be moved to 776?", true)
  
  if agree("Should 024$z be copied to 776?", true)
    move_024_z = true
  else
    move_024_z = false
  end #if agree("Should 020$z be copied to 776?", true)
  
  
  puts "\n\n-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
  puts "Main entry and title"
  puts "-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
  if agree("Should main entry/title be moved to 776?", true)
    move_me_title = true
  else
    move_me_title = false
  end #if agree("Should main entry/title be moved to 776?", true)
  
  def isbn_value(sf) 
    return sf.value.isbn
  end
 
  def _024_value(sf)
    return sf.value
  end 
  
  def lccn_value(sf)
    sf.extend(LCCN)
    return sf.get_776_format(sf.value)
end
  
  def copy_std_num_to_776(rec, tag, code)
    fields = rec.getField(tag)
    if fields
      fields.each do |f|
        f.each do |sf|
          if sf.code == code
            a = isbn_value(sf) if tag == '020'
            a = _024_value(sf) if tag == '024'
            a = lccn_value(sf) if tag == '010'
            c = 'z' if tag == '020' || tag == '024'
            c = 'w' if tag == '010' || tag == '035'            
          end #if sf.code      
      
          return [c, a] unless @the776.include?(a)
        end #f.each do
      end #fields.each do
    end #if fields
  end
  
  reader.each do |rec|
   @the776 = []
   
    if rec.getField('776')
      @ex776 = rec.find {|field| field.tag =~ /776/ }
      @ex776.each {|sf| @the776.push([sf.code, sf.value])}
    else
        writer.write(rec) unless create_776 == true
    end #if rec.getField('776')
    
    if change_c_to_i == true
      thesf = ['i']      
      subfield_c = @ex776.getSubfield('c')
      if change_i_value == true
        thesf.push(i_value)
      else
        thesf.push(subfield_c)
      end #if change_i_value = true
      @the776.push(thesf)
    end #if change_c_to_i = true
    
    @the776.push(['i', i_value]) if new_i == true
    @the776.push(['c', c_value]) if change_c_value == true
        
    if move_me_title == true
      title_proper = rec.subfieldValue('245', 'a').omitInitialArticle
      title_inclusive_dates = rec.subfieldValue('245', 'f')
      title_bulk_dates = rec.subfieldValue('245', 'g')
      title_form = rec.subfieldValue('245', 'k')
      title_number_of_part = rec.subfieldValue('245', 'n')
      title_name_of_part = rec.subfieldValue('245', 'p')
      title_to_move = title_proper
      
      title_to_move << " #{title_inclusive_dates}" if title_inclusive_dates
      title_to_move << " #{title_bulk_dates}" if title_bulk_dates
      title_to_move << " #{title_form}" if title_form
      title_to_move << " #{title_number_of_part}" if title_number_of_part
      title_to_move << " #{title_name_of_part}" if title_name_of_part
      
      main_entry_field = rec.getField('^1..')
      title_moved = 0
      
      if main_entry_field
        if main_entry_field.size > 1
          puts "ERROR: Only one main entry allowed per record"
          main_entry_errors.push(rec.get001Value)
        else
          main_entry_field = main_entry_field[0]
          main_entry_tag = main_entry_field.tag
          if main_entry_tag == '130'
            @the776.push(['t', main_entry_field.value])
            @the776.push(['7', 'un'])
            title_moved = 1
          elsif main_entry_tag == '100'
            @the776.push(['a', main_entry_field.value])
            @the776.push(['7', "p#{main_entry_field.indicator1}"])
          elsif main_entry_tag == '110'
            @the776.push(['a', main_entry_field.value])
            @the776.push(['7', "c#{main_entry_field.indicator1}"])
          elsif main_entry_tag == '111'
            @the776.push(['a', main_entry_field.value])
            @the776.push(['7', "m#{main_entry_field.indicator1}"])
          end #if main_entry_tag == '130'
        end #if main_entry_field.size > 1
      end #if main_entry_field
      
      @the776.push(['t', title_to_move]) unless title_moved == 1
      
    end #if move_me_title = true 
    @the776.push(copy_std_num_to_776(rec, '020', 'a')) if move_020_a == true
    @the776.push(copy_std_num_to_776(rec, '024', 'a')) if move_024_a == true
    @the776.push(copy_std_num_to_776(rec, '010', 'a')) if move_010_a == true    
    @the776.push(copy_std_num_to_776(rec, '020', 'z')) if copy_020_z == true
 
    rec.fields.delete(rec.find {|f| f.tag == '010'}) if rec.find {|f| f.tag == '010'} && move_010_a == true
    rec.fields.delete(rec.find {|f| f.tag == '024'}) if rec.find {|f| f.tag == '024'} && move_024_a == true
    
    rec.fields.delete(@ex776) if @ex776
    rec.append(MARC::DataField.new('776', '0', '8'))
    p @the776
    @the776.each do |sf|
      unless sf == nil
        rec.find {|f| f.tag == '776'}.append(MARC::Subfield.new(sf[0],sf[1]))
        end
    end
    writer.write(rec)
  end #reader.each do |rec|
  
  # -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
  # Error reporting
  # -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
  if main_entry_errors.size > 0
    puts "\n\n-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
    puts "Main Entry Errors!"
    puts "-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
    puts main_entry_errors
  end #if main_entry_errors.size > 0
  
  
  
end #timer