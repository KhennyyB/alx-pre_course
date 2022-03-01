unless ENV['DEBIAN_DISABLE_RUBYGEMS_INTEGRATION']

  class << Gem
    OPERATING_SYSTEM_DEFAULTS = {
      "ssl_ca_cert" => '/etc/ssl/certs/ca-certificates.crt'
    }.freeze

    alias upstream_default_dir default_dir
    def default_dir
      File.join('/', 'var', 'lib', 'gems', RbConfig::CONFIG['ruby_version'])
    end

    alias upstream_default_bindir default_bindir
    def default_bindir
      File.join('/', 'usr', 'local', 'bin')
    end

    alias upstream_default_path default_path
    def default_path
      arch = RbConfig::CONFIG['arch']
      api_version = RbConfig::CONFIG['ruby_version']

      upstream_default_path + [
        "/usr/lib/ruby/gems/#{api_version}",
        File.join('/usr/share/rubygems-integration', api_version),
        '/usr/share/rubygems-integration/all',
        "/usr/lib/#{arch}/rubygems-integration/#{api_version}"
      ].compact
    end

    # This was not defined in ruby2.5, and is now defined again in ruby2.7;
    # therefore the alias call must be conditional
    alias :upstream_default_specifications_dir :default_specifications_dir if RUBY_VERSION >= '2.7'
    def default_specifications_dir
      File.join(Gem.upstream_default_dir, 'specifications', 'default')
    end
  end

  if (RUBY_VERSION >= '2.1') && (RUBY_VERSION < '2.7')
    class << Gem::BasicSpecification
      alias upstream_default_specifications_dir default_specifications_dir
      def default_specifications_dir
        Gem.default_specifications_dir
      end
    end
  end

  if RUBY_VERSION >= '2.7'
    class Gem::Specification
      begin
        alias :upstream_rubyforge_project= :rubyforge_project=
        def rubyforge_project=(x)
        end
      rescue NameError
        # rubyforge_project= was removed in RubyGems 3.1.4
        # If method rubyforge_project= is not present, that's ok
      end
    end
  end

end
