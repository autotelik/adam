# An Excel file helper. Create and populate XSL files
# 
# jar added to class path in manifest - 'poi-3.5-beta4-20081128.jar'
# 

class JExcelFile

  include_class 'org.apache.poi.poifs.filesystem.POIFSFileSystem'
  include_class 'org.apache.poi.hssf.usermodel.HSSFCell'
  include_class 'org.apache.poi.hssf.usermodel.HSSFWorkbook'
  include_class 'org.apache.poi.hssf.usermodel.HSSFCellStyle'
  include_class 'org.apache.poi.hssf.usermodel.HSSFDataFormat'

  include_class 'java.io.ByteArrayOutputStream'
  include_class 'java.util.Date'
  include_class 'java.io.FileInputStream'

  attr_accessor :book, :row
  
  attr_reader   :sheet

  def self.date_format
    HSSFDataFormat.getBuiltinFormat("m/d/yy h:mm")
  end
  
  # The HSSFWorkbook uses 0 based indexes, whilst our companion jexcel_win32 classe
  # uses 1 based indexes. So they can be used interchangeably we bring indexes 
  # inline with  JExcel usage in this class, as 1 based maps more intuitievly for the user
  # 
  # i.e Row 1 passed to this class, internally means Row 0
  
  def initialize()
    @book = nil
  end

  def open(filename)
    inp = FileInputStream.new(filename)

    @book = HSSFWorkbook.new(inp)
    @current_sheet = 0
    sheet(@current_sheet)
  end
  
  def create(sheet_name)
    @book = HSSFWorkbook.new()
    @sheet = @book.createSheet(sheet_name.gsub(" ", ''))
    date_style = @book.createCellStyle()
    date_style.setDataFormat( JExcelFile::date_format )
  end

  # Return the current or specified HSSFSheet
  def sheet(i = nil)
    @current_sheet = i if i
    @sheet = @book.getSheetAt(@current_sheet)
  end

  def num_rows
    @sheet.getPhysicalNumberOfRows
  end

  # Process each row. (type is org.apache.poi.hssf.usermodel.HSSFRow)

  def each_row
    @sheet.rowIterator.each { |row| yield row }
  end


  # Create new row, bring index in line with POI usage (our 1 is their 0)
  def create_row(index)
    @row = @sheet.createRow(index - 1)
    @row
  end
  
  def set_cell(row, column, data)
    @row = @sheet.getRow(row - 1) || create_row(row)
    @row.createCell(column - 1).setCellValue(data)
  end

  def value(row, column)
    raise TypeError, "Expect row argument of type HSSFRow" unless row.is_a?(Java::OrgApachePoiHssfUsermodel::HSSFRow)
    cell_value( row.getCell(column) )
  end
  
  def cell_value(cell)
    case (cell.getCellType())
    when HSSFCell::CELL_TYPE_FORMULA then return cell.getCellFormula()

    when HSSFCell::CELL_TYPE_NUMERIC then return cell.getNumericCellValue()

    when HSSFCell::CELL_TYPE_STRING then return cell.getStringCellValue()
    end
  end
  
  def save( filename )
    File.open( filename, 'w') {|f| f.write(to_s) }
  end


  # The internal representation of a Excel File
  
  def to_s
    outs = ByteArrayOutputStream.new
    @book.write(outs);
    outs.close();
    String.from_java_bytes(outs.toByteArray)
  end
 
end
  
module ExcelHelper
  require 'java'

  include_class 'org.apache.poi.poifs.filesystem.POIFSFileSystem'
  include_class 'org.apache.poi.hssf.usermodel.HSSFCell'
  include_class 'org.apache.poi.hssf.usermodel.HSSFWorkbook'
  include_class 'org.apache.poi.hssf.usermodel.HSSFCellStyle'
  include_class 'org.apache.poi.hssf.usermodel.HSSFDataFormat'
  include_class 'java.io.ByteArrayOutputStream'
  include_class 'java.util.Date'

  # ActiveRecord Helper - Export model data to XLS file format
  #
  def to_xls(items=[])

    @excel = ExcelFile.new(items[0].class.name)
    
    @excel.create_row(0)
  
    sheet = @excel.sheet

    # header row
    if !items.empty?
      row = sheet.createRow(0)
      cell_index = 0
      items[0].class.columns.each do |column|
        row.createCell(cell_index).setCellValue(column.name)
        cell_index += 1
      end
    end

    # value rows
    row_index = 1
    items.each do |item|
      row = sheet.createRow(row_index);

      cell_index = 0
      item.class.columns.each do |column|
        cell = row.createCell(cell_index)
        if column.sql_type =~ /date/ then
          millis = item.send(column.name).to_f * 1000
          cell.setCellValue(Date.new(millis))
          cell.setCellStyle(dateStyle);
        elsif column.sql_type =~ /int/ then
          cell.setCellValue(item.send(column.name).to_i)
        else
          value = item.send(column.name)
          cell.setCellValue(item.send(column.name)) unless value.nil?
        end
        cell_index += 1
      end
      row_index += 1
    end
    @excel.to_s
  end
end