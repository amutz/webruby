desc "create mruby build configuration"
task Webruby.build_config => Webruby.build_dir do |t|
  Webruby::create_file_if_different(Webruby.build_config) do |f|
    f.puts <<__EOF__
# This file is generated by machine, DO NOT EDIT THIS FILE!
MRuby::Build.new do |conf|
  toolchain :gcc
  conf.build_dir = '#{Webruby.full_build_dir}/mruby/host'

  conf.gembox 'default'
end

MRuby::Toolchain.new(:emscripten) do |conf|
  toolchain :clang

  conf.cc do |cc|
    cc.command = '#{EMCC}'
    cc.flags = '#{Webruby::App.config.cflags}'
  end

  conf.linker.command = '#{EMLD}'
  conf.archiver.command = '#{EMAR}'
end

MRuby::CrossBuild.new('emscripten') do |conf|
  toolchain :emscripten
  conf.build_dir = '#{Webruby.full_build_dir}/mruby/emscripten'
  conf.gem_clone_dir = '#{File.expand_path("~/.webruby/gems")}'

  #{Webruby::App.config.gembox_lines}
  #{Webruby::App.config.gem_lines}
end
__EOF__
  end
end

desc "build mruby library"
task :libmruby => Webruby.build_config do |t|
  sh "cd #{MRUBY_DIR} && MRUBY_CONFIG=#{Webruby.full_build_config} ./minirake #{Webruby.full_build_dir}/#{LIBMRUBY}"
end

desc "mruby test library"
task :libmruby_test => Webruby.build_config do |t|
  sh "cd #{MRUBY_DIR} && MRUBY_CONFIG=#{Webruby.full_build_config} ./minirake #{Webruby.full_build_dir}/#{MRBTEST}"
end
