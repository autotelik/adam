## Copyright:: (c) Kubris & Autotelik Media Ltd 2008
## Author ::   Tom Statter
## Date ::     Nov 2008
## License::   MIT ?
##
## A wrapper around Excel Automation via ActiveX and the java library - JACOB
#
## TODO - Probably not needed now win32ole should be supported in JRUIby 1.6 +
#
##$CLASSPATH << File.expand_path(File.dirname(__FILE__) + "/" + '../../lib/java/jacob.jar')
#
#
##module Jacob
##  java_import 'com.jacob.com.Dispatch'
##  java_import 'com.jacob.activeX.ActiveXComponent'
##end
#
require 'excel_win32'

class JExcelWin32 < ExcelWin32
end
#
#  attr_accessor :excel
#
#  # To avoid creating the default workbook/sheets, e.g. to only open a file, set start_sheets = 0
#
#  def initialize( start_sheets = 3)
#    @start_sheets = start_sheets
#    @excel = Jacob::ActiveXComponent.new("Excel.Application").getObject()
#
#    unless start_sheets == 0
#      active_work_book
#      set_sheets  @start_sheets
#    end
#  end
#
#  def open( file )
#    work_books.invoke( 'Open', file )
#
#    active_work_book
#  end
#
#  def close( file )
#    work_books.invoke( 'Close', file )
#  end
#
#  def method_missing(methodname, *args)
#    begin
#      puts "INVOKE #{methodname}"
#      return @excel.invoke(methodname.to_s)
#    rescue
#      puts "INVOKE WORKBOOK"
#      return @workbook.invoke(methodname.to_s)
#    end
#  end
#
#
#  #########################
#  # ACCESS EXCEL ELEMENTS #
#  #########################
#
#  # A set of helpers to access the internal components of the spreedsheet
#
#  ## WORKBOOKS ##
#
#  def work_books()
#    @workbooks = @excel.getPropertyAsComponent('WorkBooks')
#    @workbooks
#  end
#
#  def active_work_book()
#    if(work_books.getProperty('Count').getInt == 0)
#      add_work_book
#    end
#
#    @active_work_book = @excel.getPropertyAsComponent('ActiveWorkBook')
#
#    @active_work_book
#  end
#
#  # WORKSHEETS #
#
#  # Populate and return 'Sheets' property of Active Workbook
#  #
#  def sheets
#    active_work_book  # check user hasn't closed it manually
#
#    @sheets = @active_work_book.getPropertyAsComponent('Sheets')
#    @sheets
#  end
#
#  ## THE ACTIVE SHEET ##
#
#  def active_sheet()
#    #puts "SHEET #{@workbook.methods.sort.inspect}"
#    active_work_book
#
#    @active_sheet = @active_work_book.getPropertyAsComponent('ActiveSheet')
#  end
#
#  # Return the requested sheet or the current active sheet
#  # N.B First index is 1 into the collection of all worksheets
#  #
#  def sheet( num = nil )
#    return active_sheet if( num.nil? || num > sheet_count)
#
#    sheets.invokeGetComponent("Item", com.jacob.com.Variant.new(num) )
#  end
#
#  def sheet_count
#    sheets.getProperty('Count').getInt
#  end
#
#  def active_sheet_index()
#    active_sheet.getProperty('Index').toInt
#  end
#
#  def sheet_name()
#    active_sheet.getProperty( 'Name' )
#  end
#
#  def cells( sheet_num = nil)
#    sheet(sheet_num).getPropertyAsComponent("Cells")
#  end
#
#  def item(row, col, sheet_num = nil)
#    cells(sheet_num).invokeGetComponent("Item", com.jacob.com.Variant.new(row), com.jacob.com.Variant.new(col) )
#  end
#
#  # Return a range from 2 Items
#  # TODO check params are right class
#
#  def range(r0,c0,rn,cn, sheet_num = nil)
#    first = item(r0,c0, sheet_num)
#    last  = item(rn,cn, sheet_num)
#
#    address = "#{first.getProperty('Address')}:#{last.getProperty('Address')}"
#
#    sheet(sheet_num).invokeGetComponent("Range", com.jacob.com.Variant.new( address ) )
#  end
#
#  #############################
#  # MANIPULATE EXCEL ELEMENTS #
#  #############################
#
#  # Add a new workbook, this becomes the active workbook.
#  #
#  def add_work_book()
#    @workbook = @workbooks.invokeGetComponent("Add")
#    @active_work_book = @excel.getPropertyAsComponent('ActiveWorkBook')
#  end
#
#  # Set the Active sheet
#
#  def set_active_sheet( index )
#    @excel.Sheets(index).Activate unless (index > sheets.Count)
#  end
#
#  # N.B excel.SheetsInNewWorkbook = xxx  is retained in user's preferences
#  # even after we quit  so don't use!
#
#  def set_sheets( number )
#    sheets  # ensure @sheets poulated
#    return if @sheets.nil?
#
#    index = number < 1  ? 1 : number
#
#    max = sheet_count
#    min = max
#
#    while(max > index)
#      del_sheet( max )
#      max -= 1
#    end
#    while(min < index)
#      add_sheet
#      max += 1
#    end
#  end
#
#  # Add a new sheet to active workbook
#  #
#  def add_sheet( sheet_name = nil )
#    sheets.invokeGetComponent("Add")
#    set_sheet_name(sheet_name) unless sheet_name.nil?
#  end
#
#  def del_sheet( i )
#    max = sheet_count
#    if(max > 1 && max >= i)
#      s = @sheets.invokeGetComponent("Item", com.jacob.com.Variant.new(i) )
#      s.invoke("Delete") unless s.nil?
#    end
#  end
#
#  def set_sheet_name( n )
#    active_sheet.setProperty( 'Name', n )  unless n.empty?
#  end
#
#  ################################
#  # POPULATE AND MANIPULATE DATA #
#  ################################
#
#
#  # Get/set value on a single cell, indexes start at 1
#  #
#  def set_cell( row, col, data, sheet_num = nil)
#    #puts "IN SET CELL - DATA [#{data}]"
#    begin
#      if(data.is_a?(String) && (data[0].chr == "="))
#        #puts "SET FORMULA"
#        Jacob::Dispatch.put( item(row, col, sheet_num), "Formula", data )
#      else
#        item(row, col, sheet_num).setProperty('Value', data )
#      end
#    rescue
#      puts "FAILED TO SET CELL DATA TO [#{data}]"
#    end
#
#    # Jacob::Dispatch.put( item(row, col, sheet_num), "Value", 3 )
#  end
#
#  def get_cell( row, col, sheet_num = nil)
#    item(row, col, sheet_num).getProperty('Value')
#    # this also works
#    #Jacob::Dispatch.get( item(row, col, sheet_num), "Value")
#  end
#
#  #  Populate a range of cells with data in an array
#  #  Also supports 2D arrays which are arranged over multiple rows
#  #  The co-ordinates give start position as fixed number, with first index = 1
#  #  e.g. range(2, 2, [1, 5, 56.7])
#  #
#  # => []..
#  #    [][1][5][56.7]
#  #    [] ..
#  #
#  #  e.g. range(2, 2, [[1, 5], [56.7, 23]])
#  #
#  # => []..
#  #    [][1][5]
#  #    [][56.7][23]
#  #    [] ..
#  #
#  def set_range( r0, c0, data, sheet_num = nil)
#    if( data.first.class == Array)
#      data.each_with_index do |arr, i|
#        row = r0 + i
#        put_array( row, c0, row, c0 + arr.size - 1, arr, sheet_num)
#      end
#    else
#      put_array( r0, c0, r0, (c0 + data.size - 1), data, sheet_num)
#    end
#  end
#
#  def put_array(r0, c0, rn, cn, data, sheet_num = nil)
#
#    v  = com.jacob.com.Variant.new
#    sa = com.jacob.com.SafeArray.new( com.jacob.com.Variant::VariantString, data.size)
#    sa.fromStringArray( data.to_java(:String) )
#
#    v.putSafeArray( sa )
#    range(r0,c0,rn, cn, sheet_num).setProperty('Value', v )
#  end
#
#  # Rtns :
#  #  [r0,c0][][][][]
#  #  [][][][][]
#  #  [][][][][rn,cn]
#  #
#  # TODO - This is aweful - basically it returns a string and I cant find any info on this stuff ..
#  # the result is of type - Java::ComJacobCom::Variant, and the java type is SafeArray
#  #irb(main):104:0> result = @jexcel.get_range( 1, 2, 1, 5)
#  #=> #<Java::ComJacobCom::Variant:0x1880b02 @java_object= AB CD EF GH
#  #irb(main):105:0> x = result.to_java_object
#  #=> #<Java::ComJacobCom::SafeArray:0x136193e @java_object= AB CD EF GH
#
#  # calling result.to_s gives  " AB CD EF GH\n"
#  def get_range( r0, c0, rn, cn, sheet_num = nil)
#
#    range(r0, c0, rn, cn, sheet_num).getProperty('Value')
#    # Gives same return type
#    # Jacob::Dispatch.get( range(r0, c0, rn, cn, sheet_num), "Value")
#  end
#
#  ###########
#  # HELPERS #
#  ###########
#
#  def invoke(methodname)
#    @excel.invoke(methodname.to_s)
#  end
#
#  # Make Excel visible or not to user - expects TRUE or FALSE
#
#  def visible( on_off = true)
#    @excel.setProperty('Visible', on_off)
#  end
#
#end
#
