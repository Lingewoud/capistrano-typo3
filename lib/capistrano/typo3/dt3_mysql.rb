class DT3MySQL

  def self.mysql_executable_dir
    if fetch(:rake_mysql_exec_dir)
      return fetch(:rake_mysql_exec_dir)
    else
      return '/usr/bin'
    end
  end

  def self.flush_tables
    DT3Logger::log('Flushing tables')
    tablelist =	 `#{self.create_mysql_base_command} -e "show tables" | grep -v Tables_in | grep -v "+"`
    dropsql = ''
    tablelist.split("\n").each {|table|
      dropsql +="drop table #{table};"
    }
    self.mysql_execute(dropsql)
    return true
  end

  def self.show_tables
    return self.mysql_execute('show tables')
  end

  def self.truncate_table(table)
    self.mysql_execute("TRUNCATE TABLE #{table};")
  end

  def self.create_mysql_base_command_with(user,host,password,db,exec='mysql')
    cmd = "#{self.mysql_executable_dir}/#{exec} -u#{user} -h#{host} -p#{password} #{db}"
    DT3Logger::log('mysql command:',cmd,'debug')
    return cmd
  end

  def self.test_connection
    stdout = self.mysql_execute('SHOW TABLES;')
    if stdout.include? 'denied'
      return false
    else
      return 1
    end
  end

  def self.dump_db_version(name=nil, table_exclude_list=nil)

    if not File.directory?(TYPO3_DB_DUMP_DIR)
      FileUtils.mkdir TYPO3_DB_DUMP_DIR
    end

    filename =''
    numbers = []
    dbsettings = Typo3Helper::get_db_settings

    if name
      filename = File.join(TYPO3_DB_DUMP_DIR,"#{dbsettings['name']}-#{ENV['name']}.sql")
      version = name
    else
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

      filename = File.join(TYPO3_DB_DUMP_DIR,"#{dbsettings['name']}.#{version.to_s}.sql")
    end

    print "new image:#{dbsettings['name']} version:#{version}\n"
    DT3MySQL::mysqldump_to(filename,table_exclude_list)
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
        image['time'] = File.mtime(sql).strftime("%Y-%m-%d")
        image['filename'] = sql

        images_arr << image
      end
    }
    return images_arr
  end

  def self.create_exclude_list

    table_exclude_list = %w( be_users be_sessions cache_* cf_* fe_session_data fe_sessions static_countries \
    static_country_zones static_currencies static_languages static_territories sys_history sys_log tx_devlog \
    zzz_deleted_* )

    tables = self.show_tables
    table_arr = tables.split("\n")

    substr_arr = []
    excltable_arr = []
    realexclude_list = []

    table_exclude_list.each {|excltable|
      if(excltable.include? '*')
        substr_arr << excltable[0,excltable.index('*')]
      else
        excltable_arr << excltable
      end
    }

    table_arr.each {|table|
      if(excltable_arr.include?(table))
        realexclude_list << table
      else
        substr_arr.each {|substr|
          if(table[0,substr.length] == substr)
            realexclude_list << table
          end
        }
      end
    }

    return realexclude_list.uniq
  end

  def self.create_mysql_base_command(exec='mysql')
    return self.create_mysql_base_command_with(fetch(:dbuser),fetch(:dbhost),fetch(:dbpass),fetch(:dbname),exec)
  end

  def self.mysql_execute(sql)
    "#{self.create_mysql_base_command} -e \"#{sql}\""
  end

  def self.create_exclude_string(excludelist,db)
    s = ''
    excludelist.each {|extab|
      if(s.length>0)
        s += " "
      end
      s += "--ignore-table=#{db}.#{extab}"
    }
    return s
  end

  def self.mysqldump_to(outputfile,excludelist=nil,no_schema=nil)

    if(not excludelist.nil?)
      excludestring = self.create_exclude_string(excludelist,db)
      DT3Logger::log('Dumping with excludelist',excludestring,'debug')
    else
      excludestring = ''
    end

    cmd="#{create_mysql_base_command('mysqldump')} #{excludestring} > #{outputfile}"
    DT3Logger::log('Executing SQL',cmd,'debug')
    system(cmd)
  end

  def self.mysql_import(user,pass,host,db,insqlfile)
    cmd ="#{create_mysql_base_command} < #{insqlfile}"
    DT3Logger::log('Executing import',cmd,'debug')
    system(cmd)
  end
end
