module PEBuild::Release

  two_eight_x = newrelease do

    add_release :debian, 6

    add_release :el, 5
    add_release :el, 6

    add_release :sles, 11

    add_release :solaris, 10

    add_release :ubuntu, '10.04'
    add_release :ubuntu, '12.04'

    add_release :windows, '2003'
    add_release :windows, '2008R2'
    add_release :windows, 7

    # PE 2.8 adds support for AIX, but as of 2013-08-12 Vagrant has nothing
    # remotely resembling support for AIX WPARs or LPARs. Since it's meaningless
    # to try to add support for AIX, we just leave this commented out.
    #
    # add_release :aix, '5.3'
    # add_release :aix, '6.1'
    # add_release :aix, '7.1'

    set_answer_file :master, File.join(PEBuild.template_dir, 'answers', 'master-2.x.txt.erb')
    set_answer_file :agent,  File.join(PEBuild.template_dir, 'answers', 'agent-2.x.txt.erb')
  end

  @releases['2.8.1'] = two_eight_x
  @releases['2.8.2'] = two_eight_x
  @releases['2.8.3'] = two_eight_x
end
