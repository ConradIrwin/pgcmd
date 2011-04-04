require 'heroku/command'
module Heroku
  module Command
    class Addons
      include PGResolver

      alias configure_addon_without_pg configure_addon
      def configure_addon(label, &install_or_upgrade)
        %w[fork track].each do |opt|
          if val = extract_option("--#{opt}")
            db = Resolver.new(val, config_vars)
            display db.message if db.message
            abort_with_database_list(val) unless db[:url]

            db_plan = HerokuPostgresql::Client10.new(db[:url]).get_database[:plan]
            addon_plan = args.first.split(/:/)[1] || 'ronin'
            abort " !  only another #{db_plan} can #{opt} #{db[:name]}" unless db_plan == addon_plan

            args << "#{opt}=#{db[:url]}"
          end
        end
        configure_addon_without_pg(label, &install_or_upgrade)
      end
    end
  end
end
