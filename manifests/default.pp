class install-git-server {
	include apache

	$git_repo_home = '/home/vagrant/site.git'

	package { ["vim","curl","git-core","bash"]:
	    ensure => present,
	    require => Exec["apt-get update"]
  	}

  	exec { 'apt-get update':
	    command => '/usr/bin/apt-get update'
	}

	exec { 'create webroot tree':
		command => 'mkdir -p /home/vagrant/site/src/www',
		creates => '/home/vagrant/site/src/www',
		path    => "/usr/bin/:/bin/",
	}

	exec { 'set webroot permissions':
		command => 'sudo chown -R vagrant:vagrant ./site',
		cwd => '/home/vagrant',
		user => 'vagrant',
		path    => "/usr/bin/:/bin/",
		require => Apache::Vhost['gitserver.local'],
	}


	file { '/home/vagrant/site.git':
		ensure => 'directory',
		owner => 'vagrant',
	}

	ssh_authorized_key { 'install public key':
		ensure => 'present',
		key => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQDFW5oiChewx7SUyfLQaVmwpcjg02AfKuAlF2UWe3cRx2AU0RgAQYVLtkZaRd4P4t/NQoZIl3ht3q6mHfio8nCQpLtVAJQI5Q8I7X/TRm/7pVqDKp3KGoGlHlIHSIJcVbWOu/+QfZ/yMU2kxkg5PY1zEecN7vUARzfutJNlr3LU2wUR8aDj1ZN+uWaF1Z7aK0z9AhLUGrwFSMUCHeVhC6fmXRkrCn463Rh0InYh/KYh4ECgbz3ef9gfpE61KpL8bQyVP0PlcP9Jg4tKn8Ywn5iRjUlSGEOr91RgIC0A2HxAwJiV6af104kfnPk2hpNTBQPqabQqHunsp5yEEd4vip0P',
		name => 'vagrant-example-key',
		user => 'vagrant',
		type => 'ssh-rsa',
	}

	exec { 'create git repo':
		command => '/usr/bin/git --bare init',
		cwd => '/home/vagrant/site.git',
		creates => "${git_repo_home}/hooks",
		require => [
			File["${git_repo_home}"],
			Package['git-core']
			],
		user => 'vagrant',
	}

	file { 'create post-commit hook':
		path => "${git_repo_home}/hooks/post-receive",
		content => template('gitserver/post-receive.sh'),
		require => Exec['create git repo'],
	}

	exec { 'make post-commit hook executable':
		command => "/bin/chmod +x ${git_repo_home}/hooks/post-receive",
		require => File['create post-commit hook'],
	}

	apache::vhost { 'gitserver.local':
	    priority        => '10',
	    vhost_name      => '192.168.66.10',
	    port            => '80',
	    docroot         => '/home/vagrant/site/src/www/',
	    serveraliases   => ['gitserver.local',],
	    require => Exec['create webroot tree'],
	}
}

include install-git-server



