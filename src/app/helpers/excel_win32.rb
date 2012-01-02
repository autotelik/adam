# = Basic wrapper around win32ole interface to Excel   
#
#		Acts as proxy - will call OLE methods directly - forward on any methods not defined here
#		
#		For example to get the active row
#			@excel.ActiveCell.Row
#
# USAGE :
# 
#     @excel = Excel.new
# 
#     @excel.visible( TRUE )    
#      
#     @excel.add_sheet( "MySheet" )
#      
#     @excel.cell(1, 1, "A single cell")
#      
#     @excel.range(2, 1, 2, 3, [1, 5, 56.7])
#          
# Author::    Tom Statter
# Copyright:: (c) Lloyds TSB Group Plc 2007
# License::   ALL RIGHTS RESERVED
#


#BROKEN ON MAC - How to make Platform independent?
#require 'win32ole'

class ExcelWin32

  attr_accessor :workbook, :excel

  def initialize( start_visible = false)

    @excel = WIN32OLE.new("Excel.application")
    
    @excel.visible = start_visible
    
	end

	
	def method_missing(methodname, *args)       
		begin 
			@excel.send(methodname, *args)  
		rescue
			  @workbook.send(methodname, *args)
		end
	end
	
	def open( file )
    @excel.Workbooks.Open file
    
    @workbook = @excel.ActiveWorkBook
    
  end

  # Add a new workbook, this becomes the active workbook.
  # 
  def add_workbook( start_sheets = 3 ) 
    @workbook = @excel.Workbooks.Add()
    
    # N.B excel.SheetsInNewWorkbook = 1 
    # is retained even after we quit in user's preferences
      
    start_sheets = 1 if start_sheets < 1 
      
    while(sheets.Count > start_sheets)
      @workbook.Worksheets( sheets.Count ).Delete
    end
      
    while(sheets.Count < start_sheets)
      add_sheet
    end
  end  
  
  ##############
  # WORKSHEETS #
  ##############
  
	
  # Add a new sheet to active workbook
  # 
  def add_sheet( sheet_name = nil )
		@workbook.Worksheets.Add
		
		set_sheet_name(sheet_name) unless sheet_name.nil?
  end
	
	def del_sheet( i )
		@workbook.Worksheets( i ).Delete if(sheets.Count > 1 && sheets.Count >= i)
	end
	
  # Return collection of all worksheets from active Workbook
  # N.B this array is a 1-based index
  # s
  def sheets
    @workbook = @excel.ActiveWorkbook

    add_workbook if(@workbook.nil?)     # check user hasn't closed it manually
    
    @workbook.Worksheets
  end
  
  # Return the requested sheet or the current active sheet
	# N.B First index is 1 into the collection of all worksheets
  # 
  def sheet( num = nil )
    return @workbook.ActiveSheet if( num.nil? || num > sheets.Count)
    
    sheets( num )    
  end
  
  def active_sheet()
    @workbook.ActiveSheet
  end
	
  def active_sheet_index()
  	@workbook.ActiveSheet.Index
  end
			
	# Set the Active sheet
	
  def set_active_sheet( index )
  	@excel.Sheets(index).Activate unless (index > sheets.Count) 
  end
		
	def sheet_name( n )
		@workbook.ActiveSheet.Name
	end
		
	def set_sheet_name( n )
		@workbook.ActiveSheet.Name = n  unless n.empty?
	end
  
  ########
  # DATA #
  ########
  
  # Populate a single cell with data
  # 
  def cell( row, col, data, sheet_num = nil)  
    sheet(sheet_num).Cells(row, col).Value = data
  end
  
	def get_active_cell
		@excel.ActiveCell.Value
	end
	
	def set_active_cell( value )
		@excel.ActiveCell.Value = value
	end
	
	def set_offset( x, y, value )
		@excel.ActiveCell.Offset(x,y).Value = value
	end
	
  #  Populate a range of cells with data in an array 
  #  where the co-ordinates relate to start and end position ...
  #  
  #  [r0,c0][][][][]
  #  [][][][][]
  #  [][][][][rn,cn]
  #
  #  e.g. range(2, 2, 2, 4, [1, 5, 56.7])
  #  
  # => []..
  #    [][1][5][56.7]
  #    [] ..
  #    
  def range( r0, c0, rn, cn, data, sheet_num = nil)
    
    curr_sheet = sheet(sheet_num)
        
    first = curr_sheet.Cells(r0,c0).Address   
    last  = curr_sheet.Cells(rn,cn).Address 

    curr_sheet.Range("#{first}:#{last}").Value = data
  end    
  
  
  # Rtns :
  #  [r0,c0][][][][]
  #  [][][][][]
  #  [][][][][rn,cn]
	  
  def get_range( r0, c0, rn, cn, sheet_num = nil)
    
    curr_sheet = sheet(sheet_num)
        
    first = curr_sheet.Cells(r0,c0).Address   
    last  = curr_sheet.Cells(rn,cn).Address 

    curr_sheet.Range("#{first}:#{last}").Value
  end
  
  ###########
  # HELPERS #
  ###########
  
  # Make Excel visible or not to user - expects TRUE or FALSE
  
  def visible( on_off = true)
    @excel.visible = on_off
  end
  
  
end

# TESTING - IRB scripts
# 
#data = [
#["2", "375-12.5", "Boyced", "2007/04/04", "TRAC#105 - Corrected name for base validation method", "src/stk/fxclientapi/cValForex.cpp"], 
#["1", "3c", "Schafera", "2003/08/05", "", "src/stk/fxclientapi/cValForex.cpp"],
#["1", "BAD LINE", "TOM", "2003/08/05"], 
#[""],
#["28", "375-12.5", "Boyced", "2007/04/04", "TRAC#105 - Added code to PreDBWrite to update discount indexes on mirror forex trades - Added code to Fill ", "src/stk/fxclientapi/cValForexTrade.cpp"], 
#["27", "375-10", "Chlouchd", "2007/01/17", "", "src/stk/fxclientapi/cValForexTrade.cpp"] ]
#
#require 'win32ole'
#
#excel = WIN32OLE.new("Excel.application")
#
#workbook = excel.Workbooks.Add()
#sheet    = workbook.Worksheets(1)
#excel.visible = TRUE
#first = sheet.Cells(2,1).Address
#last = sheet.Cells( data.size + 1,6).Address
#sheet.Range("#{first}:#{last}").Value = data

# names = workbook.ole_methods.collect {|m| m.name }
# names.sort

#excel.ole_get_methods.each do | e|
#  print e.to_s, " : PARAMS ["
#  print e.params, "]\n\n"
#end
#
#workbook.ole_get_methods.each do | e|
#  print e.to_s, " : PARAMS ["
#  print e.params, "]\n\n"
#end
#
#workbook.ole_func_methods.each do | e|
#  print e.to_s, " : PARAMS ["
#  print e.params, "]\n\n"
#end
#
#      
#sheet.ole_func_methods.each do | e|
#  print e.to_s, " : PARAMS ["
#  print e.params, "]\n\n"
#end
#
#sheet.ole_get_methods.each do | e| 
#  print e.to_s, " : PARAMS ["
#  print e.params, "] : [", sheet.ole_method_help( e.to_s ).params, "]\n\n"
#end
#
#sheet.ole_get_methods.each do | e|
#  print e.to_s, " : PARAMS ["
#  print e.params, "]\n\n"
#end
#
#sheet.ole_put_methods.each do | e|
#  print e.to_s, " : PARAMS ["
#  print e.params, "]\n\n"
#end
