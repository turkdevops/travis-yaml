require 'bundler/setup'
require 'travis/yaml'
require 'sinatra'
require 'slim'
require 'gh'

get '/' do
  slim ""
end

get '/style.css' do
  sass :style
end

post '/' do
  halt 400, 'needs repo or yml' unless params[:repo] or params[:yml]
  params[:yml] ||= GH["https://api.github.com/repos/#{params[:repo]}/contents/.travis.yml?ref=master"]['content'].to_s.unpack('m').first
  @result = Travis::Yaml.parse(params[:yml])
  slim :result
end

error GH::Error do
  halt 400, slim("ul.result\n  li failed to fetch <b class='error'>.travis.yml</b>")
end

__END__

@@ result

- if @result.nested_warnings.empty?
  p.result Hooray, your .travis.yml seems to be solid!
- else
  ul.result
    - @result.nested_warnings.each do |key, warning|
      li
        - if key.any?
          | in <b class="error">#{key.join('.')}</b> section:
          = " "
        == slim('= error', {}, error: warning).gsub(/&quot;(.+?)&quot;/, '<b class="error">\1</b>')

@@ layout

html
  head
    title Validate your .travis.yml file
    link rel="stylesheet" type="text/css" href="/style.css"
  body
    h1
      a href="/" Travis WebLint
    p.tagline
      | Uses <a href="https://github.com/travis-ci/travis-yaml">travis-yaml</a> to check your .travis.yml config.

    == yield

    form class="first" action="/" method="post" accept-charset="UTF-8"
      label for="repo" Enter your Github repository
      input type="text" id="repo" name="repo" maxlength="80" placeholder="travis-ci/travis-yaml" value=params[:repo]
      input type="submit" value="Validate"

    form action="/" method="post" accept-charset="UTF-8"
      label for="yml" Or paste your .travis.yml
      textarea id="yml" name="yml" maxlength="10000" = params[:yml]
      input type="submit" value="Validate"

@@ style

// http://meyerweb.com/eric/tools/css/reset/
// v2.0 | 20110126
// License: none (public domain)

html, body, div, span, applet, object, iframe, h1, h2, h3, h4, h5, h6, p, blockquote, pre, a, abbr, acronym, address, big, cite, code, del, dfn, em, img, ins, kbd, q, s, samp, small, strike, strong, sub, sup, tt, var, b, u, i, center, dl, dt, dd, ol, ul, li, fieldset, form, label, legend, table, caption, tbody, tfoot, thead, tr, th, td, article, aside, canvas, details, embed, figure, figcaption, footer, header, hgroup, menu, nav, output, ruby, section, summary, time, mark, audio, video
  margin: 0
  padding: 0
  border: 0
  font-size: 100%
  font: inherit
  vertical-align: baseline

// HTML5 display-role reset for older browsers
article, aside, details, figcaption, figure, footer, header, hgroup, menu, nav, section
  display: block

body
  line-height: 1

ol, ul
  list-style: none

blockquote, q
  quotes: none

blockquote
  &:before, &:after
    content: ''
    content: none

q
  &:before, &:after
    content: ''
    content: none

table
  border-collapse: collapse
  border-spacing: 0

// General

body
  margin: 2em auto 2em auto
  width: 960px
  font-size: 14px
  line-height: 1.4286
  color: #555
  background: #fff
  font-family: "Helvetica Neue", Arial, Verdana, sans-serif

b
  font-weight: bold

a
  color: #36c
  outline: none
  text-decoration: underline

a:visited
  color: #666

a:hover
  color: #6c3
  text-decoration: none

h1
  color: #000
  font-size: 4em
  font-weight: bold
  line-height: 1em

h1 a:link, h1 a:visited, h1 a:hover, h1 a:active
  color: #000
  text-decoration: none

h2
  font-size: 2em
  font-weight: bold
  line-height: 2em

p.tagline
  color: #777
  display: block
  font: italic 1.25em Georgia, Times, Serif
  line-height: 1.67em
  margin: 1em 0 4em 0
  padding: 0 0 1.25em 0
  border-bottom: 1px solid #ccc

// Result

.result
  font-size: 1.5em
  margin-bottom: 4em

p.result
  color: #6c3

ul.result
  list-style: none

ul.result li:before
  content: ">"
  display: inline-block
  background-color: #c00
  color: #fff
  width: 1.4em
  height: 1.4em
  font-size: 40%
  margin-right: 1em
  text-align: center
  position: relative
  top: -0.5em

// Form

form
  display: inline-block
  vertical-align: top
  width: 475px

form.left
  margin-right: 55px

label, input
  display: block

label
  margin-bottom: 0.5em

input, textarea
  font-size: 14px
  line-height: 1.4286
  color: #555
  font-family: "Helvetica Neue", Arial, Verdana, sans-serif
  border: 1px solid #ccc
  margin: 0

input[type=text]
  padding: 4px 8px
  width: 400px

input[type=submit]
  background: #efefef
  padding: 4px 8px
  margin-top: 0.5em

input[type=submit]:hover
  cursor: pointer

textarea
  padding: 4px 8px
  width: 460px
  height: 250px

// Various

.error
  color: #c00
