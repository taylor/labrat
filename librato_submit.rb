#!/usr/bin/env ruby
require 'librato/metrics'
require 'yaml'
require 'json'
require 'pp'

@config = YAML::load(File.read("#{ENV['HOME']}/.librato.yml"))
Librato::Metrics.authenticate @config['email'], @config['api_token']

@queue = Librato::Metrics::Queue.new

def process_json(pattern,&block)
  Dir.glob("./*#{pattern}.json") do |json|
    begin
      data = JSON.parse(File.read(json))
      name = data['system']['name'] if data and data['system'] and data['system']['name']
      name ||= json.split("-#{pattern}.json").to_s.split("/").last.gsub(/\"/,'').gsub(/\]/,'')
      if data and data['status'] and data['status']['value'] == "OK"
        yield(data,name,json)
      end
    rescue Exception => e
      puts "Could not read #{json} #{e.message}"
    end
  end
end

def librato_load
  process_json("load") { |data,name,json|
    puts "putting name:#{name}"
    data['data'].each_pair do |k,v|
      @queue.add "load_#{k}" => { :type => :gauge, :value => v, :source => name }
    end
  }
end

def librato_memfree
  process_json("memfree") { |data,name,json|
    puts "putting name:#{name}"
    data['data'].each_pair do |k,v|
      @queue.add "memfree_#{k}" => { :type => :gauge, :value => v, :source => name }
    end
  }
end

def librato_netstat
  process_json("netstat") { |data,name,json|
    puts "putting name:#{name}"
    data['data'].each_pair do |k,v|
      @queue.add "netstat_#{k}" => { :type => :counter, :value => v, :source => name }
    end
  }
end

def librato_redis
  process_json("redis") { |data,name,json|
    puts "putting name:#{name}"
    @queue.add "redis_server_lru_clock" => { :type => :counter, :value => data['data']['server']['lru_clock'].to_f, :source => name } #"=>"834472",
    @queue.add "redis_server_redis_git_dirty" => { :type => :gauge, :value => data['data']['server']['redis_git_dirty'].to_f, :source => name } #"=>"0",
    @queue.add "redis_server_uptime_in_days" => { :type => :gauge, :value => data['data']['server']['uptime_in_days'].to_f, :source => name } #"=>"54",
    @queue.add "redis_server_process_id" => { :type => :gauge, :value => data['data']['server']['process_id'].to_f, :source => name } #"=>"3063",
    @queue.add "redis_server_tcp_port" => { :type => :gauge, :value => data['data']['server']['tcp_port'].to_f, :source => name } #"=>"6379",
    @queue.add "redis_server_uptime_in_seconds" => { :type => :counter, :value => data['data']['server']['uptime_in_seconds'].to_f, :source => name } #"=>"4742360",
    @queue.add "redis_server_arch_bits" => { :type => :gauge, :value => data['data']['server']['arch_bits'].to_f, :source => name } #"=>"64"}
    @queue.add "redis_stats_evicted_keys" => { :type => :counter, :value => data['data']['stats']['evicted_keys'].to_f, :source => name } #"=>"0",
    @queue.add "redis_stats_keyspace_hits" => { :type => :counter, :value => data['data']['stats']['keyspace_hits'].to_f, :source => name } #"=>"35532",
    @queue.add "redis_stats_instantaneous_ops_per_sec" => { :type => :counter, :value => data['data']['stats']['instantaneous_ops_per_sec'].to_f, :source => name } #"=>"0",
    @queue.add "redis_stats_keyspace_misses" => { :type => :counter, :value => data['data']['stats']['keyspace_misses'].to_f, :source => name } #"=>"254250",
    @queue.add "redis_stats_pubsub_channels" => { :type => :counter, :value => data['data']['stats']['pubsub_channels'].to_f, :source => name } #"=>"0",
    @queue.add "redis_stats_latest_fork_usec" => { :type => :counter, :value => data['data']['stats']['latest_fork_usec'].to_f, :source => name } #"=>"722",
    @queue.add "redis_stats_pubsub_patterns" => { :type => :counter, :value => data['data']['stats']['pubsub_patterns'].to_f, :source => name } #"=>"0",
    @queue.add "redis_stats_rejected_connections" => { :type => :counter, :value => data['data']['stats']['rejected_connections'].to_f, :source => name } #"=>"0",
    @queue.add "redis_stats_total_commands_processed" => { :type => :counter, :value => data['data']['stats']['total_commands_processed'].to_f, :source => name } #"=>"497800",
    @queue.add "redis_stats_total_connections_received" => { :type => :counter, :value => data['data']['stats']['total_connections_received'].to_f, :source => name } #"=>"9949",
    @queue.add "redis_stats_expired_keys" => { :type => :counter, :value => data['data']['stats']['expired_keys'].to_f, :source => name } #"=>"133"}
    @queue.add "redis_persistence_rdb_last_bgsave_time_sec" => { :type => :gauge, :value => data['data']['persistence']['rdb_last_bgsave_time_sec'].to_f, :source => name } #"=>"0",
    @queue.add "redis_persistence_aof_enabled" => { :type => :gauge, :value => data['data']['persistence']['aof_enabled'].to_f, :source => name } #"=>"0",
    @queue.add "redis_persistence_rdb_bgsave_in_progress" => { :type => :gauge, :value => data['data']['persistence']['rdb_bgsave_in_progress'].to_f, :source => name } #"=>"0",
    @queue.add "redis_persistence_aof_current_rewrite_time_sec" => { :type => :gauge, :value => data['data']['persistence']['aof_current_rewrite_time_sec'].to_f, :source => name } #"=>"-1",
    @queue.add "redis_persistence_aof_last_rewrite_time_sec" => { :type => :gauge, :value => data['data']['persistence']['aof_last_rewrite_time_sec'].to_f, :source => name } #"=>"-1",
    @queue.add "redis_persistence_aof_rewrite_scheduled" => { :type => :gauge, :value => data['data']['persistence']['aof_rewrite_scheduled'].to_f, :source => name } #"=>"0",
    @queue.add "redis_persistence_aof_rewrite_in_progress" => { :type => :gauge, :value => data['data']['persistence']['aof_rewrite_in_progress'].to_f, :source => name } #"=>"0",
    @queue.add "redis_persistence_rdb_changes_since_last_save" => { :type => :gauge, :value => data['data']['persistence']['rdb_changes_since_last_save'].to_f, :source => name } #"=>"0",
    @queue.add "redis_persistence_loading" => { :type => :gauge, :value => data['data']['persistence']['loading'].to_f, :source => name } #"=>"0",
    @queue.add "redis_persistence_rdb_current_bgsave_time_sec" => { :type => :gauge, :value => data['data']['persistence']['rdb_current_bgsave_time_sec'].to_f, :source => name } #"=>"-1",
    @queue.add "redis_persistence_rdb_last_save_time" => { :type => :counter, :value => data['data']['persistence']['rdb_last_save_time'].to_f, :source => name } #"=>"1371492071"}
    @queue.add "redis_memory_used_memory_lua" => { :type => :gauge, :value => data['data']['memory']['used_memory_lua'].to_f, :source => name } #"=>"31744",
    @queue.add "redis_memory_used_memory_peak" => { :type => :gauge, :value => data['data']['memory']['used_memory_peak'].to_f, :source => name } #"=>"1012256",
    @queue.add "redis_memory_used_memory" => { :type => :gauge, :value => data['data']['memory']['used_memory'].to_f, :source => name } #"=>"921560",
    @queue.add "redis_memory_used_memory_rss" => { :type => :gauge, :value => data['data']['memory']['used_memory_rss'].to_f, :source => name } #"=>"2453504"}
    @queue.add "redis_cpu_used_cpu_sys_children" => { :type => :gauge, :value => data['data']['cpu']['used_cpu_sys_children'].to_f, :source => name } #"=>"3.14",
    @queue.add "redis_cpu_used_cpu_user_children" => { :type => :gauge, :value => data['data']['cpu']['used_cpu_user_children'].to_f, :source => name } #"=>"1.61",
    @queue.add "redis_cpu_used_cpu_sys" => { :type => :counter, :value => data['data']['cpu']['used_cpu_sys'].to_f.to_f, :source => name } #"=>"11058.11",
    @queue.add "redis_cpu_used_cpu_user" => { :type => :counter, :value => data['data']['cpu']['used_cpu_user'].to_f, :source => name } #"=>"4907.12"}
    @queue.add "redis_clients_client_biggest_input_buf" => { :type => :gauge, :value => data['data']['clients']['client_biggest_input_buf'].to_f, :source => name } #"=>"0",
    @queue.add "redis_clients_client_longest_output_list" => { :type => :gauge, :value => data['data']['clients']['client_longest_output_list'].to_f, :source => name } #"=>"0",
    @queue.add "redis_clients_blocked_clients" => { :type => :gauge, :value => data['data']['clients']['blocked_clients'].to_f, :source => name } #"=>"4",
    @queue.add "redis_clients_connected_clients" => { :type => :gauge, :value => data['data']['clients']['connected_clients'].to_f, :source => name } #"=>"8"}
    @queue.add "redis_replication_connected_slaves" => { :type => :gauge, :value => data['data']['replication']['connected_slaves'].to_f, :source => name } #"=>"0",
  }
end

def librato_vmstat
  process_json("vmstat") { |data,name,json|
    puts "putting name:#{name}"
    @queue.add  "vmstat_CPU_context_switches" => { :type => :gauge, :value => data['data']['CPU_context_switches'], :source => name }
    @queue.add  "vmstat_IO-wait_cpu_ticks" => { :type => :gauge, :value => data['data']['IO-wait_cpu_ticks'], :source => name }
    @queue.add  "vmstat_IRQ_cpu_ticks" => { :type => :gauge, :value => data['data']['IRQ_cpu_ticks'], :source => name }
    @queue.add  "vmstat_K_active_memory" => { :type => :gauge, :value => data['data']['K_active_memory'], :source => name }
    @queue.add  "vmstat_K_buffer_memory" => { :type => :gauge, :value => data['data']['K_buffer_memory'], :source => name }
    @queue.add  "vmstat_K_free_memory" => { :type => :gauge, :value => data['data']['K_free_memory'], :source => name }
    @queue.add  "vmstat_K_free_swap" => { :type => :gauge, :value => data['data']['K_free_swap'], :source => name }
    @queue.add  "vmstat_K_inactive_memory" => { :type => :gauge, :value => data['data']['K_inactive_memory'], :source => name }
    @queue.add  "vmstat_K_swap_cache" => { :type => :gauge, :value => data['data']['K_swap_cache'], :source => name }
    @queue.add  "vmstat_K_total_memory" => { :type => :gauge, :value => data['data']['K_total_memory'], :source => name }
    @queue.add  "vmstat_K_total_swap" => { :type => :gauge, :value => data['data']['K_total_swap'], :source => name }
    @queue.add  "vmstat_K_used_memory" => { :type => :gauge, :value => data['data']['K_used_memory'], :source => name }
    @queue.add  "vmstat_K_used_swap" => { :type => :gauge, :value => data['data']['K_used_swap'], :source => name }
    @queue.add  "vmstat_boot_time" => { :type => :gauge, :value => data['data']['boot_time'], :source => name }
    @queue.add  "vmstat_forks" => { :type => :counter, :value => data['data']['forks'], :source => name }
    @queue.add  "vmstat_idle_cpu_ticks" => { :type => :counter, :value => data['data']['idle_cpu_ticks'], :source => name }
    @queue.add  "vmstat_interrupts" => { :type => :counter, :value => data['data']['interrupts'], :source => name }
    @queue.add  "vmstat_nice_user_cpu_ticks" => { :type => :counter, :value => data['data']['nice_user_cpu_ticks'], :source => name }
    @queue.add  "vmstat_non-nice_user_cpu_ticks" => { :type => :counter, :value => data['data']['non-nice_user_cpu_ticks'], :source => name }
    @queue.add  "vmstat_pages_paged_in" => { :type => :counter, :value => data['data']['pages_paged_in'], :source => name }
    @queue.add  "vmstat_pages_paged_out" => { :type => :counter, :value => data['data']['pages_paged_out'], :source => name }
    @queue.add  "vmstat_pages_swapped_in" => { :type => :counter, :value => data['data']['pages_swapped_in'], :source => name }
    @queue.add  "vmstat_pages_swapped_out" => { :type => :counter, :value => data['data']['pages_swapped_out'], :source => name }
    @queue.add  "vmstat_softirq_cpu_ticks" => { :type => :counter, :value => data['data']['softirq_cpu_ticks'], :source => name }
    @queue.add  "vmstat_stolen_cpu_ticks" => { :type => :counter, :value => data['data']['stolen_cpu_ticks'], :source => name }
    @queue.add  "vmstat_system_cpu_ticks" => { :type => :counter, :value => data['data']['system_cpu_ticks'], :source => name }
  }
end

def librato_ping
  process_json("load") { |data,name,json|
    puts "putting name:#{name}"
    @queue.add  "ping_time_#{data['ip']}" => { :type => :gauge, :value => data['ping_time'], :source => name }
  }
end

librato_load
librato_memfree
librato_netstat
librato_redis
librato_vmstat
librato_ping