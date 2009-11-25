module Vault
  module S3
    OPTIONS = {:authenticated => false, :access => :public_read}

    def write_gem
      cache_path = "gems/#{spec.original_name}.gem"
      VaultObject.store(cache_path, body.string, OPTIONS)

      quick_path = "quick/Marshal.4.8/#{spec.original_name}.gemspec.rz"
      Gemcutter.indexer.abbreviate spec
      Gemcutter.indexer.sanitize spec
      VaultObject.store(quick_path, Gem.deflate(Marshal.dump(spec)), OPTIONS)
    end

    def upload(key, value)
      final = StringIO.new
      gzip = Zlib::GzipWriter.new(final)
      gzip.write(Marshal.dump(value))
      gzip.close

      # For the life of me, I can't figure out how to pass a stream in here from a closed StringIO
      VaultObject.store(key, final.string, OPTIONS)
    end

    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def unlink(spec)
        cache_path = "gems/#{spec.original_name}.gem"
        if VaultObject.exists?(cache_path)
          VaultObject.delete(cache_path)
        end

        quick_path = "quick/Marshal.4.8/#{spec.original_name}.gemspec.rz"
        if VaultObject.exists?(quick_path)
          VaultObject.delete(quick_path)
        end
      end
    end
  end

  module FS
    def write_gem
      cache_path = Gemcutter.server_path('gems', "#{spec.original_name}.gem")
      File.open(cache_path, "wb") do |f|
        f.write body.string
      end
      File.chmod 0644, cache_path

      quick_path = Gemcutter.server_path("quick", "Marshal.4.8", "#{spec.original_name}.gemspec.rz")
      FileUtils.mkdir_p(File.dirname(quick_path))

      Gemcutter.indexer.abbreviate spec
      Gemcutter.indexer.sanitize spec
      File.open(quick_path, "wb") do |f|
        f.write Gem.deflate(Marshal.dump(spec))
      end
      File.chmod 0644, quick_path
    end

    def upload(key, value)
      final = StringIO.new
      gzip = Zlib::GzipWriter.new(final)
      gzip.write(Marshal.dump(value))
      gzip.close

      File.open(Gemcutter.server_path(key), "wb") do |f|
        f.write final.string
      end
    end

    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def unlink(spec)
        cache_path = Gemcutter.server_path('gems', "#{spec.original_name}.gem")
        if File.exists?(cache_path)
          File.unlink(cache_path)
        end

        quick_path = Gemcutter.server_path("quick", "Marshal.4.8", "#{spec.original_name}.gemspec.rz")
        if File.exists?(quick_path)
          File.unlink(quick_path)
        end
      end
    end
  end
end
