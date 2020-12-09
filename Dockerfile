FROM ruby:2.7
RUN gem install bundler
WORKDIR /usr/src/app
#COPy ./data/dotorochirc /root/.orochirc
COPY . .
RUN bundle install
RUN rm -r pkg | bundle exec rake build orochi_for_medusa.gemspec
RUN gem install pkg/orochi-for-medusa-*.gem
#CMD ["/bin/bash"]
