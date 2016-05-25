class DT3Div
  def self.downloadTo(src_url,src_path,dest_filepath)
    p src_url
    p src_path
    p dest_filepath
    Net::HTTP.start(src_url) { |http2|
      resp2 = http2.get(src_path)
      open(dest_filepath, "w+") { |file2|
        file2.write(resp2.body)
      }
    }
    return true
  end

  def self.checkValidDir(dir)
    if dir!= '..' and dir != '.' and dir!= '.svn' and dir!= '.git'
      return true
    else
      return false
    end
  end

  def self.rmsymlink(symlink)
    if File.symlink?( symlink )
      FileUtils.rm_r( symlink )
    end
  end

  def self.hashlist_to_table_string(hashlist)

    if(hashlist.count < 1)
      return
    end

    table = Text::Table.new
    table.head = []
    table.rows = []

    hashlist[0].each {|key,val|
      table.head << key
    }
    hashlist.each {|keyd_row|
      row = []
      keyd_row.each {|key,val|
        row << val
      }
      table.rows << row
    }

    return table.to_s
  end
end
