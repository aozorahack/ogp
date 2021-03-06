# -*- coding:shift_jis -*-
require 'aozora2html'
require 'optparse'
require "tempfile"

# override Aozora2Html#push_chars
#
# Original Aozora2Html#push_chars does not convert "'" into '&#39;'; it's old behaivor
# of CGI.escapeHTML().
#
class UnEmbed_Gaiji_tag
  def to_s
    "［#{@desc}］".encode("shift_jis")
  end
end
class Editor_note_tag
  def to_s
    ""
  end
end
class Multiline_style_tag
  def close_tag
    ""
  end
  def to_s
    ""
  end
end
class Font_size_tag
  def close_tag
    ""
  end
  def to_s
    ""
  end
end
class Jizume_tag
  def close_tag
    ""
  end
  def to_s
    ""
  end
end
class Keigakomi_tag
  def close_tag
    ""
  end
  def to_s
    ""
  end
end
class Multiline_yokogumi_tag
  def close_tag
    ""
  end
  def to_s
    ""
  end
end
class Multiline_caption_tag
  def close_tag
    ""
  end
  def to_s
    ""
  end
end
class Multiline_midashi_tag
  def close_tag
    ""
  end
  def to_s
    ""
  end
end
class Jisage_tag
  def close_tag
    ""
  end
  def to_s
    ""
  end
end
class Chitsuki_tag
  def close_tag
    ""
  end
  def to_s
    ""
  end
end
class Midashi_tag
  def to_s
    "#{@target.to_s}".encode("shift_jis")
  end
end
class Ruby_tag
  def to_s
    "#{@target.to_s}（#{@ruby.to_s}）".encode("shift_jis")
  end
end
class Kaeriten_tag
  def to_s
    "#{@string.to_s}".encode("shift_jis")
  end
end
class Okurigana_tag
  def to_s
    "#{@string.to_s}".encode("shift_jis")
  end
end
class Inline_keigakomi_tag
  def to_s
    "#{@target.to_s}".encode("shift_jis")
  end
end
class Inline_yokogumi_tag
  def to_s
    "#{@target.to_s}".encode("shift_jis")
  end
end
class Inline_caption_tag
  def to_s
    "#{@target.to_s}".encode("shift_jis")
  end
end
class Inline_font_size_tag
  def to_s
    "#{@target.to_s}".encode("shift_jis")
  end
end
class Decorate_tag
  def to_s
    "#{@target.to_s}".encode("shift_jis")
  end
end
class Dakuten_katakana_tag
  def to_s
    "#{@katakana.to_s}&#x3099".encode("shift_jis") # U+3099: COMBINING KATAKANA-HIRAGANA VOICED SOUND MARK
  end
end
class Dir_tag
  def to_s
    "#{@target.reverse.to_s}".encode("shift_jis")
  end
end
class Img_tag
  def to_s
    "#{@alt.to_s}".encode("shift_jis")
  end
end

class Aozora2Html
  def push_chars(obj)
    if obj.is_a?(Array)
      obj.each{|x|
        push_chars(x)
      }
    elsif obj.is_a?(String)
      if obj.length == 1
        obj = obj.gsub(/[&\"<>]/, {'&' => '&amp;', '"' => '&quot;', '<' => '&lt;', '>' => '&gt;'})
      elsif obj[0] == '<'
        obj = ""
      end
      obj.each_char{|x|
        push_char(x)
      }
    else
      push_char(obj)
    end
  end

  def dispatch_gaiji
    hook = @stream.peek_char(0)
    if hook ==  "［".encode("shift_jis")
      read_char
      # embed?
      command,raw = read_to_nest("］".encode("shift_jis"))
      try_emb = kuten2png(command)
      if try_emb != command
        try_emb
      elsif command.match(/U\+([0-9A-F]{4,5})/)
        unicode_num = $1
        ch = Embed_Gaiji_tag.new(self, nil, nil, command)
        ch.unicode = unicode_num
        ch
      else
        # Unemb
        escape_gaiji(command)
      end
    else
      "※".encode("shift_jis")
    end
  end

  def process_header
  end
  def finalize
  end
  def ending_check
    if @stream.peek_char(0) == "本".encode("shift_jis") and @stream.peek_char(1) == "："
      @section = :tail
      ensure_close
    end
  end
  def tail_output
    ruby_buf_dump
    string = @buffer.join
    string.gsub(/[&\"<>]/, {'&' => '&amp;', '"' => '&quot;', '<' => '&lt;', '>' => '&gt;'})
    @ruby_buf = [""]; @ruby_buf_mode = nil; @buffer = []
    @out.print string, "\r\n"
  end
end

def get_src_file(src_file)
  if src_file =~ /\Ahttps?:/
    require 'open-uri'
    down_file = File.join(@dir, File.basename(src_file))
    begin
      open(down_file, "wb") do |f0|
        open(src_file){|f1| f0.write(f1.read)}
      end
      src_file = down_file
    rescue
      $stderr.print "file not found: #{src_file}\n"
      $stderr.print "Download Error: #{$!}\n"
      exit 1
    end
  else
    if !File.exist?(src_file)
      $stderr.print "file not found: #{src_file}\n"
      exit 1
    end
  end
  src_file
end

def get_raw_file(src_file,ext,tmpfile_name)
  if File.extname(src_file) == ".zip"
    tmpfile = File.join(@dir, tmpfile_name)
    ::Zip::File.open(src_file) do |zip_file|
      entry = zip_file.glob(ext).first
      entry.extract(tmpfile)
    end
    src_file = tmpfile
  end
  src_file
end

opt = OptionParser.new("Usage: aozora2unicode [options] <file> [<text file>]\n")
opt.on('--apply-ogp CSV', 'aozora csv file')
opt.version = Aozora2Html::VERSION
options = opt.getopts

Accent_tag.use_jisx0213 = true
Embed_Gaiji_tag.use_jisx0213 = true
Embed_Gaiji_tag.use_unicode = true

if ARGV.size < 1 || ARGV.size > 2
  $stderr.print opt.banner
  exit 1
end

src_file, dest_file = ARGV[0], ARGV[1]
title = ""

Dir.mktmpdir do |dir|
  @dir = dir
  if options["apply-ogp"]
    src_file = get_src_file(src_file)
    csv_file = get_src_file(options["apply-ogp"])
    csv_file = get_raw_file(csv_file, "*.csv", "aozora.csv")
    card_file = src_file
    if File.basename(card_file).match(/([0-9]+)/)
      number = format("%06d", $1.to_i)
    else
      $stderr.print "#{card_file} is invalid file name\n"
      exit 1
    end
    File.open(csv_file, 'r:UTF-8') do |file|
      file.each_line do |line|
        if line.match("^\"#{number}\",\"([^\"]*)\"")
          title = $1
          if line.match(/(http[^,]+\.zip)/)
            src_file = $1
          else
            $stderr.print "zip URL not found in #{csv_file}\n"
            exit 1
          end
        end
      end
    end
  end
  if dest_file.nil?
    dest_file = File.join(dir, "output.txt")
  end
  src_file = get_src_file(src_file)
  src_file = get_raw_file(src_file, "*.txt", "aozora.txt")
  Aozora2Html.new(src_file, dest_file).process

  output = File.read(dest_file, encoding: 'Shift_JIS:UTF-8')
  output.gsub!("<br />", "")
  output.gsub!(/&#x([0-9A-F]{4,5});/) {|unicode|
    [$1.hex].pack("U*")
  }
  File.open(dest_file, "w") do |file|
    file.print output.encode("UTF-8")
  end
  if card_file
    body = output[0, 256]
    card_file = get_src_file(card_file)
    output = File.read(card_file, encoding: 'UTF-8')
    output.gsub!("<head>".encode("UTF-8"),
    "<head prefix=\"og: http://ogp.me/ns#\">\r\n" +
    "<meta property=\"og:type\" content=\"book\">\r\n" +
    "<meta property=\"og:image\" content=\"http://www.aozora.gr.jp/images/top_logo.png\">\r\n" +
    "<meta property=\"og:image:type\" content=\"image/png\">\r\n" +
    "<meta property=\"og:image:width\" content=\"100\">\r\n" +
    "<meta property=\"og:image:height\" content=\"100\">\r\n" +
    "<meta property=\"og:title\" content=\"#{title}\">\r\n" +
    "<meta property=\"og:description\" content=\"#{body.encode("UTF-8")+"……".encode("UTF-8")}\">\r\n" +
    "<meta name=\"twitter:card\" content=\"summary\" />\r\n".encode("UTF-8"))
    File.open(dest_file, "w") do |file|
      file.print output.encode("UTF-8")
    end
  end
  if !ARGV[1]
    output = File.read(dest_file)
    print output
  end
end
