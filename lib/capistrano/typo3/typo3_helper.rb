require 'open-uri'
require 'json'

class Typo3Helper

  def self.typo3_version_list

    source = "https://get.typo3.org/json"
    content = ""
    open(source) do |s|
      content = s.read
    end

    my_hash = JSON.parse(content)
    _version_arr= []

    my_hash.each do |k,v|

      if(v['releases'])

        v['releases'].each do |rel,relprops|
          _version_arr << rel
        end
      end

    end

    return  _version_arr.uniq.sort
  end

  def self.get_typo3_versions

    version_arr = self.typo3_version_list
    return_string = ""
    version_arr.each { |v|
      return_string << "TYPO3 version: "+ v+ "\n"
    }

    return return_string
  end

  # from 4.7.12 it should return 12
  def self.minor_version total_version
    version_m = total_version.split "."
    return version_m[2]
  end

  # from 4.7.12 it should return 4.7
  def self.major_version total_version
    version_m = total_version.split "."
    return "#{version_m[0]}.#{version_m[1]}"
  end

  def self.typo3_version_list_for_table
    version_arr = []
    idx = 0
    versions_list_in = []
    versions = Typo3Helper::get_typo3_versions
    versions_list_in << Typo3Helper::last_minor_version(versions,'6.2')
    versions_list_in << Typo3Helper::last_minor_version(versions,'7.0')
    versions_list_in << Typo3Helper::last_minor_version(versions,'7.6')
    versions_list_in << Typo3Helper::last_minor_version(versions,'8.1')

    versions_list_in.each {|version_in|
      idx = idx+1
      version = Hash.new
      version['index'] = idx
      version['main version'] = self.major_version version_in
      version['last minor version'] = version_in

      version_arr << version
    }
    return version_arr
  end

  def self.php_exexcutable
    if(CONFIG['PHPEXEC'])
      return CONFIG['PHPEXEC']
    else
      return 'php'
    end
  end

  # Get last minor version bases on configuration or argument, e.g 6.2 returns ATOW 6.2.9
  def self.typo3_last_version(version=nil)

    if version.nil?
      version = CONFIG['TYPO3_MAIN_VERSION']
    end

    if version.split('.').count == 3
      #DT3Logger::log("Pinned to minor version","#{version}")
      typo3_version = version
    else
      versions = self.get_typo3_versions
      typo3_version = Typo3Helper::last_minor_version(versions,version.to_s)
    end

    return typo3_version
  end

  def self.download_typo3_source version

    tarball= "typo3source/typo3_src-#{version}.tar.gz"

    unless File.directory?('typo3source')
      FileUtils.mkdir('typo3source')
    end

    unless File.exist?(tarball)
      if(CONFIG['TYPO3_ALTERNATIVE_SOURCE_URL'])
        DT3Logger::log("Downloading source tarball from","#{CONFIG['TYPO3_ALTERNATIVE_SOURCE_URL']}")
        altsrc = CONFIG['TYPO3_ALTERNATIVE_SOURCE_URL']
        srcurl = altsrc[7..(altsrc.index('/',8)-1)]
        srcpath = altsrc[(altsrc.index('/',8))..-1]
        version = altsrc[altsrc.index('typo3_src-')+10,6]

        DT3Div::downloadTo(srcurl,srcpath,tarball)
      else
        srcurl = "get.typo3.org"
        srcpath = "/#{version}"

        DT3Logger::log("Downloading source tarball from","https://get.typo3.org/#{version}")
        DT3Div::downloadTo(srcurl,srcpath,tarball)
      end
    end

    DT3Logger::log("Unpacking source tarballs")
    if File.directory?(File.join('typo3source', "typo3_src-#{version}"))
      FileUtils.rm_r(File.join('typo3source',"typo3_src-#{version}"))
    end
    system("tar xzf #{tarball} -C typo3source/")
  end

  def self.last_minor_version(versions, majorversion)
    list = []
    versions.each_line do |line|
      if(line[15,3]==majorversion)
        if(line.chomp[19,2].to_s.match(/\A[+-]?\d+?(\.\d+)?\Z/))
          list << sprintf('%02d',line.chomp[19,2])
        end
      end
    end
    return majorversion+"."+list.sort.reverse[0].to_i.to_s
  end

  def self.flush_config_cache()
    DT3Logger::log('flush_cache','removing cache files','debug')
    system("rm -Rf current/dummy/typo3conf/temp_CACHED_*")
  end

  def self.flush_cache()
    DT3Logger::log('flush_cache','removing cache files','debug')
    system("rm -Rf current/dummy/typo3temp/*")
    DT3Logger::log('flush_cache','truncating typo3temp','debug')
    system("rm -Rf current/dummy/typo3conf/temp_CACHED_*")
  end

  #truncates a list of tables
  def self.truncate_tables(tables)

    all_current_tables = DT3MySQL::show_tables.split("\n")

    tables.each do |table|
      if all_current_tables.include?(table)
        DT3MySQL::truncate_table(table)
      end
    end
  end

  def self.truncate_cache_tables()
    cache_tables= %w(cache_extensions cache_hash cache_imagesizes cache_md5params cache_pages cache_pagesection cache_sys_dmail_stat cache_treelist cache_typo3temp_log cachingframework_cache_hash cachingframework_cache_hash_tags cachingframework_cache_pages cachingframework_cache_pages_tags cachingframework_cache_pagesection cachingframework_cache_pagesection_tags cf_cache_hash cf_cache_hash_tags cf_cache_pages cf_cache_pages_tags cf_cache_pagesection cf_cache_pagesection_tags cf_extbase_object cf_extbase_object_tags cf_extbase_reflection cf_extbase_reflection_tags cf_tt_news_cache cf_tt_news_cache_tags cf_tx_solr cf_tx_solr_tags tt_news_cache tt_news_cache_tags tx_realurl_chashcache tx_realurl_errorlog tx_realurl_pathcache tx_realurl_uniqalias tx_realurl_urldecodecache tx_realurl_urlencodecache tx_solr_cache tx_solr_cache_tags)
    self.truncate_tables(cache_tables)
  end

  def self.truncate_session_tables()

    session_tables=%w(be_sessions fe_session_data fe_sessions)
    self.truncate_tables(session_tables)
  end

  def self.get_db_settings
    if(self.typo3_localconf_version == 6)
      cmd = "php -r \'define(\"TYPO3_MODE\", \"BE\");$arr = include \"#{TYPO3_V6_LOCAL_CONF_PATH}\";echo \"{$arr[\"DB\"][\"username\"]} {$arr[\"DB\"][\"password\"]} {$arr[\"DB\"][\"host\"]} {$arr[\"DB\"][\"database\"]}\";\'"
    elsif(self.typo3_localconf_version == 4)
      cmd = "php -r \'define(\"TYPO3_MODE\", \"BE\");include \"#{TYPO3_V4_LOCAL_CONF_PATH}\";echo \"$typo_db_username $typo_db_password $typo_db_host $typo_db\";\'"
    end

    dbsettings =%x[ #{cmd} ].split(' ')

    dbsetarr = {}
    dbsetarr['name'] = dbsettings[3]
    dbsetarr['host'] = dbsettings[2]
    dbsetarr['user'] = dbsettings[0]
    dbsetarr['password'] = dbsettings[1]

    return dbsetarr
  end

  # replaces database settings in the localconf file
  def self.set_localconf_database_settings(db,user,password,host='localhost')
    if(self.typo3_localconf_version == 6)
      cmd1 = "php -r \'define(\"TYPO3_MODE\", \"BE\");" \
        "$arr = include \"#{TYPO3_V6_LOCAL_CONF_PATH}\"; " \
        "echo \"<?php\\n\";" \
        "echo \"return \";" \
        "$arr[\"DB\"][\"username\"]=\"#{user}\"; " \
        "$arr[\"DB\"][\"database\"]=\"#{db}\";" \
        "$arr[\"DB\"][\"password\"]=\"#{password}\";" \
        "$arr[\"DB\"][\"host\"]=\"#{host}\";" \
        "var_export($arr);" \
        "echo \";\\n?>\";\'" \
        "> #{TYPO3_V6_LOCAL_CONF_PATH}.tmp"
      system cmd1

      cmd2 = "mv #{TYPO3_V6_LOCAL_CONF_PATH}.tmp #{TYPO3_V6_LOCAL_CONF_PATH}"
      system cmd2

    elsif(self.typo3_localconf_version == 4)
      text = File.read(TYPO3_V4_LOCAL_CONF_PATH)
      text = text.gsub(/^\$typo_db_password\ .*/, "$typo_db_password = '#{password}'; #{TYPO3_MODIFY_SIGNATURE}")
      text = text.gsub(/^\$typo_db\ .*/, "$typo_db = '#{db}'; #{TYPO3_MODIFY_SIGNATURE}")
      text = text.gsub(/^\$typo_db_host\ .*/, "$typo_db_host = '#{host}'; #{TYPO3_MODIFY_SIGNATURE}")
      text = text.gsub(/^\$typo_db_username\ .*/, "$typo_db_username = '#{user}'; #{TYPO3_MODIFY_SIGNATURE}")
      File.open(TYPO3_V4_LOCAL_CONF_PATH, "w") {|file| file.puts text}
    end
    return true
  end

  def self.set_v4_typo3_extconf_settings(extconfvars)
    text = File.read(TYPO3_V4_LOCAL_CONF_PATH)
    extconfvars.each do |key,arr|

      typo3_conf_vars = "$TYPO3_CONF_VARS['EXT']['extConf']['#{key}'] = '#{PHP.serialize(arr).gsub("'", "\\\\'")}'; #{TYPO3_MODIFY_SIGNATURE}"

      if text.include?("$TYPO3_CONF_VARS['EXT']['extConf']['#{key}']")
        text = text.gsub(/^\$TYPO3_CONF_VARS\['EXT'\]\['extConf'\]\['#{key}'\].*/, typo3_conf_vars)
      else
        text = text.gsub(/^\?>/, typo3_conf_vars + "\n?>")
      end

    end
    File.open(TYPO3_V4_LOCAL_CONF_PATH, "w") {|file| file.puts text}

  end

  def self.set_typo3_extconf_settings(extconfvars)
    if(self.typo3_localconf_version == 4)
      return set_v4_typo3_extconf_settings extconfvars
    elsif(self.typo3_localconf_version == 6)
      return set_v6_typo3_extconf_settings extconfvars
    end

  end

  def self.set_v6_typo3_extconf_settings(extconfvars)
      confVars = {}
      confVars['EXT'] = {}
      confVars['EXT']['extConf'] = {}

      extconfvars.each do |key,arr|
        confVars['EXT']['extConf'][key] = "#{PHP.serialize(arr).gsub("'", "\\\\'")}"
      end
      self.set_v6_typo3_conf_vars confVars
  end

  def self.set_v4_typo3_conf_vars(confvars)
    text = File.read(TYPO3_V4_LOCAL_CONF_PATH)

    confvars.each do |mainKey, mainHash|
      mainHash.each do |key,var|

        confstring = "$TYPO3_CONF_VARS['#{mainKey}']['#{key}'] = '#{var}'; #{TYPO3_MODIFY_SIGNATURE}"

        if text.include?("$TYPO3_CONF_VARS['#{mainKey}']['#{key}']")
          text = text.gsub(/^\$TYPO3_CONF_VARS\['#{mainKey}'\]\['#{key}'\].*/, confstring)
        else
          text = text.gsub(/^\?>/, confstring + "\n?>")
        end
      end
    end

    File.open(TYPO3_V4_LOCAL_CONF_PATH, "w") {|file| file.puts text}
  end

  def self.set_v6_typo3_conf_vars(confvars)

    outfile = TYPO3_V6_LOCAL_CONF_PATH

    confhash = self.get_v6_localconf_array
    confjson = confhash.deep_merge!(confvars)

    File.open('tmpjson', 'w') { |file| file.write(confjson.to_json) }

    cmd = "php -r \'define(\"TYPO3_MODE\", \"BE\");echo \"<?php\\n\";echo \"return \";$contents = file_get_contents(\"./tmpjson\"); $arr = json_decode($contents);var_export($arr);echo \";\\n?>\";\'"
    newphpconf = `#{cmd}`

    newphpconf.gsub!('))',')')
    newphpconf.gsub!('stdClass::__set_state(','')

    cmd = "rm tmpjson"
    system (cmd)
    cmd = "cp #{outfile} #{outfile}.bak"
    system (cmd)

    File.open(outfile, 'w') { |file| file.write(newphpconf) }
  end

  def self.set_typo3_conf_vars(confvars)
    if(confvars)

      if(self.typo3_localconf_version == 6)
        self.set_v6_typo3_conf_vars(confvars)

      elsif(self.typo3_localconf_version == 4)
        self.set_v4_typo3_conf_vars(confvars)

      end
    end

    return true
  end

  def self.set_localconf_extlist(extList)
    if(self.typo3_localconf_version == 4)
      self.set_v4_localconf_extlist(extList)
    elsif(self.typo3_localconf_version == 6)
      self.set_v6_localconf_extlist(extList)
    end
  end

  def self.set_v4_localconf_extlist(extList)

    extList = Typo3Helper::get_v4_localconf_extlist('extList')
    extList_fe = Typo3Helper::get_v4_localconf_extlist('extList_FE')

    CONFIG['DISABLE_EXTENSIONS'].each do |delext|
      extList.delete(delext)
      extList_fe.delete(delext)
    end

    newconf= "$TYPO3_CONF_VARS['EXT']['extList'] = '#{extList.join(',')}'"
    newconf_FE= "$TYPO3_CONF_VARS['EXT']['extList_FE'] = '#{extList_fe.join(',')}'"

    text = File.read(TYPO3_V4_LOCAL_CONF_PATH)
    text = text.gsub(/^\$TYPO3_CONF_VARS\['EXT'\]\['extList'\].*/, newconf+"; #{TYPO3_MODIFY_SIGNATURE}")
    text = text.gsub(/^\$TYPO3_CONF_VARS\['EXT'\]\['extList_FE'\].*/, newconf_FE+"; #{TYPO3_MODIFY_SIGNATURE}")

    File.open(TYPO3_V4_LOCAL_CONF_PATH, "w") {|file| file.puts text}

  end

  ## Based on a list with extKeys it set the new active extensions
  def self.set_v6_localconf_extlist(extList)

    outfile = File.join('current','dummy','typo3conf','PackageStates.php')
    confhash = self.get_v6_package_states
#	require 'pp'
#	PP.pp confhash
    confhash['packages'].each do |extKey, extAttr|
      if extList.include? extKey
        extAttr['state']='active'
      else
        extAttr['state']='inactive'
      end
      confhash['packages'][extKey] = extAttr
    end

    File.open('tmpjson', 'w') { |file| file.write(confhash.to_json) }

    cmd = "php -r \'define(\"TYPO3_MODE\", \"BE\");echo \"<?php\\n\";echo \"return \";$contents = file_get_contents(\"./tmpjson\");
      $arr_unsorted = array();
      $arr_sorted = array();
      $arr_unsorted[\"packages\"] = array();
      $arr_sorted[\"packages\"] = array();
      $arr = json_decode($contents);
      foreach($arr->packages as $key => $a){
        if($key==\"core\") $arr_sorted[\"packages\"][$key] = $a;
        else $arr_unsorted[\"packages\"][$key] = $a;
      }
      foreach($arr_unsorted[\"packages\"] as $key => $a){
        $arr_sorted[\"packages\"][$key] = $a;
      }
      $arr->packages = $arr_sorted[\"packages\"];
      var_export($arr);
      echo \";\\n?>\";\'"
    newphpconf = `#{cmd}`

    newphpconf.gsub!('))',')')
    newphpconf.gsub!('stdClass::__set_state(','')

    cmd = "rm tmpjson"
    system (cmd)
    cmd = "cp #{outfile} #{outfile}.bak"
    system (cmd)

    File.open(outfile, 'w') { |file| file.write(newphpconf) }
  end

  def self.symlink_source version
    DT3Logger::log("Linking typo3_src-#{version} with typo3_src in dummy")
    system("rm -f #{File.join('current','dummy','typo3_src')}")
    system("ln -sf ../../../typo3source/typo3_src-#{version} #{File.join('current','dummy','typo3_src')}")
    #system("cd current/dummy && ln -sf ../../../typo3source/typo3_src-#{version} typo3_src")
  end

  def self.typo3_localconf_version
    if(CONFIG['TYPO3_MAIN_VERSION'].to_s.split('.')[0].to_i > 4)
      return 6
    else
      return 4
    end
  end

  def self.typo3_localconf_file
    if self.typo3_localconf_version == 4
      return TYPO3_V4_LOCAL_CONF_PATH
    elsif self.typo3_localconf_version == 6
      return TYPO3_V6_LOCAL_CONF_PATH
    end
  end

  def self.get_v6_localconf_array
    cmd = "php -r \'define(\"TYPO3_MODE\", \"BE\");$arr = include \"#{TYPO3_V6_LOCAL_CONF_PATH}\";echo json_encode($arr);'"
    json = `#{cmd}`
    return JSON.parse(json)
  end

  def self.get_v6_package_states
    infile = File.join('current','dummy','typo3conf','PackageStates.php')
    cmd = "php -r \'define(\"TYPO3_MODE\", \"BE\");$arr = include \"#{infile}\";echo json_encode($arr);'"
    json = `#{cmd}`
    return JSON.parse(json)
  end

  def self.get_v4_localconf_array
    infile = File.join('current','dummy','typo3conf','localconf.php')
    cmd = "php -r '\define(\"TYPO3_MODE\", \"BE\");include \"#{infile}\";echo serialize($TYPO3_CONF_VARS);\'"
    ret =%x[ #{cmd} ]
    return PHP.unserialize(ret)
  end

  def self.get_localconf_extlist
    if(self.typo3_localconf_version == 6)
      confhash = self.get_v6_package_states
      activeList = []
      confhash['packages'].each do |extKey, extAttr|
         if extAttr['state']=='active'
           activeList << extKey
         end
      end
      return activeList

    elsif(self.typo3_localconf_version == 4)
      return get_v4_localconf_extlist('extList')
    end
  end

  def self.get_v4_localconf_extlist(extlistKey='extList')
      cmd = "php -r '\define(\"TYPO3_MODE\", \"BE\");include \"#{TYPO3_V4_LOCAL_CONF_PATH}\";echo $TYPO3_CONF_VARS[\"EXT\"][\"#{extlistKey}\"];\'"
      extList =%x[ #{cmd} ]
      return extList.split(',');
  end

  #unused at the moment, could be handy
  def self.get_confarray_from_localconf
    if(self.typo3_localconf_version == 6)
      return self.get_v6_localconf_array
    elsif(self.typo3_localconf_version == '4')
      return self.get_v4_localconf_array
    end
  end

  def self.get_extconfarray_from_localconf(infile)
    if(self.typo3_localconf_version == 6)
      confhash = self.get_v6_localconf_array
      extensionArr = Hash.new
      confhash['EXT']['extConf'].each {|extkey,extconf|
        extensionArr[extkey] = PHP.unserialize(extconf)
      }
      return extensionArr

    elsif
      cmd = "php -r '\define(\"TYPO3_MODE\", \"BE\");include \"#{infile}\";echo serialize($TYPO3_CONF_VARS[\"EXT\"][\"extConf\"]);\'"
      ret =%x[ #{cmd} ]

      extensionArr = Hash.new
      _extArray= PHP.unserialize(ret)
      _extArray.each {|extkey,extconf|
        extensionArr[extkey] = PHP.unserialize(extconf)

      }
      return extensionArr
    end
  end

  def self.download_ext_xml
    DT3Div.downloadTo('typo3.org','/fileadmin/ter/extensions.xml.gz','current/dummy/typo3temp/extensions.xml.gz')
    system('gunzip -c current/dummy/typo3temp/extensions.xml.gz > current/dummy/typo3temp/extensions.xml');
    return true
  end

end
