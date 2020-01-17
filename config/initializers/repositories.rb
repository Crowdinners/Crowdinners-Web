Repository.define do
    repositories provider: :github, namespace: 'Crowdinners' do
        repository :data do
            klass           Repository::Data
            repo            'Data'
            branch          'master'
            services        [:data]
        end

        visible? true do
            repository :web do
                title           "Website"
                description     "Main website and backend."
                repo            "Crowdinners-Web"
                open?           true
            end

            repository :static do
                title           "Data"
                description     "Static configuration data files."
                repo            "Crowdinners-Data"
                open?           true
            end
        end
    end
end
