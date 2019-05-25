require 'pe_build/release'

module PEBuild::Release

  twentyeighteen_one_x = newrelease do

    add_release :el, '5'
    add_release :el, '6'
    add_release :el, '7'
    add_release :el, '8'

    add_release :sles, '11'
    add_release :sles, '12'

    add_release :ubuntu, '14.04'
    add_release :ubuntu, '16.04'
    add_release :ubuntu, '18.04'

    add_release :windows, '2008'
    add_release :windows, '2008R2'
    add_release :windows, '2012'
    add_release :windows, '2012R2'
    add_release :windows, '2016'
    add_release :windows, '2019'
    add_release :windows, '7'
    add_release :windows, '8'
    add_release :windows, '8.1'
    add_release :windows, '10'

    set_answer_file :master, File.join(PEBuild.template_dir, 'answers', 'master-2016.2.x.conf.erb')
  end

  @releases['2018.1.0'] = twentyeighteen_one_x
  # RIP. 2018.1.1
  @releases['2018.1.2'] = twentyeighteen_one_x
  @releases['2018.1.3'] = twentyeighteen_one_x
  @releases['2018.1.4'] = twentyeighteen_one_x
  @releases['2018.1.5'] = twentyeighteen_one_x
  # 2018.1.6 was only shipped to AWS OpsWorks
  @releases['2018.1.7'] = twentyeighteen_one_x
  @releases['2018.1.8'] = twentyeighteen_one_x
end
