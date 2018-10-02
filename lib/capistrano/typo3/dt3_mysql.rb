class DT3MySQL

  def self.mysql_executable_dir
    if fetch(:rake_mysql_exec_dir)
      return fetch(:rake_mysql_exec_dir)
    else
      return '/usr/bin'
    end
  end

  def self.flush_tables
    tablelist = `#{self.create_mysql_base_command} -e "show tables" | grep -v Tables_in | grep -v "+"`
    dropsql = ''
    tablelist.split("\n").each {|table|
      dropsql +="drop table #{table};"
    }
    self.mysql_execute(dropsql)
  end

  def self.show_tables
    return self.mysql_execute('show tables')
  end

  def self.truncate_table(table)
    self.mysql_execute("TRUNCATE TABLE #{table};")
  end

  def self.create_mysql_base_command_with(user,host,password,db,exec='mysql')
    cmd = "#{self.mysql_executable_dir}/#{exec} -u#{user} -h#{host} -p#{password} #{db}"
    return cmd
  end

  def self.db_image_list
    images_arr = []
    idx = 0

    Dir.glob("#{TYPO3_DB_DUMP_DIR}/*.sql").sort.each {|sql|
      image = Hash.new
      if File.extname(sql) == '.sql'
        idx = idx+1
        image['index'] = idx

        image['filesize (Mb)'] = '%.2f' % (File.size(sql).to_f / 2**20)


        if(sql.split('.').count == 3)
          image['version'] = sql.split('.')[1]
          image['name'] = File.basename(sql.split('.')[0])
        elsif(sql.split('-').count == 2)
          image['version'] = sql.split('-')[1].split('.')[0]
          image['name'] = File.basename(sql.split('-')[0])
        else
          image['version'] = '[MASTER]'
          image['name'] = File.basename(sql,'.*')
        end
        image['time'] = File.mtime(sql).strftime("%Y-%m-%d %H:%M")
        image['filename'] = sql

        images_arr << image
      end
    }
    return images_arr
  end

  def self.dump_db_version(table_exclude_list=nil)

    filename =''
    numbers = []

    Dir.foreach(TYPO3_DB_DUMP_DIR) {|sql|
      tmpname = sql.split('.')
      if(tmpname.count == 3)
        numbers << tmpname[1].to_i
      end
    }
    if(numbers.count > 0)
      version = (numbers.max + 1)
    else
      version = 1
    end

    branch = `git rev-parse --abbrev-ref HEAD`.gsub("\n",'')
    filename = File.join(TYPO3_DB_DUMP_DIR,"#{fetch(:dbname)}-#{branch}.#{version.to_s}.sql")
    print "new image:#{fetch(:dbname)} version:#{version}\n"
    DT3MySQL::mysqldump_to(filename,table_exclude_list)
  end


  def self.create_mysql_base_command(exec='mysql')
    return self.create_mysql_base_command_with(fetch(:dbuser),fetch(:dbhost),fetch(:dbpass),fetch(:dbname),exec)
  end

  def self.mysql_execute(sql)
    "#{self.create_mysql_base_command} -e \"#{sql}\""
  end

  def self.create_exclude_string(excludelist)
    s = ''
    excludelist.each {|extab|
      if(s.length>0)
        s += " "
      end
      s += "--ignore-table=#{fetch(:dbname)}.#{extab}"
    }
    return s
  end

  def self.mysqldump_to(outputfile,excludelist=nil,no_schema=nil)

    if(not excludelist.nil?)
      excludestring = self.create_exclude_string(excludelist)
    else
      excludestring = ''
    end

    "#{create_mysql_base_command('mysqldump')} #{excludestring} > #{outputfile}"
  end

  def self.mysql_import(insqlfile)
    "#{create_mysql_base_command} < #{insqlfile}"
  end
end
