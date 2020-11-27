publish: install
	bundle install --path vendor/bundle
	zip -r function.zip src vendor

test: install
	bundle exec rspec 

install:
	gem install bundle
	gem install rspec   
	bundle install
