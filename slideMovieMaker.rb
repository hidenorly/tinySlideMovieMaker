#  Copyright (C) 2023, 2024 hidenorly
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'fileutils'
require 'optparse'
require 'shellwords'
require 'json'
require 'enumerator'
require_relative 'ExecUtil'
require_relative 'FileUtil'


class Converter
	def self.getDuration(soundPath, minDuration = nil)
		result = 0
		exec_cmd = "ffprobe -i #{Shellwords.escape(soundPath)} -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1"
		duration = ExecUtil.getExecResultEachLine(exec_cmd, FileUtil.getDirectoryFromPath(soundPath) )
		duration = duration[0].to_f
		result = (minDuration!=nil && duration<minDuration) ? minDuration : duration
		return result
	end


	def self.convert(imagePath, soundPath, outputPath, duration=nil, fadeInDuration=0.5, addCrossFadeDuration=false, useVideoToolBox=false, options=nil)
		if File.exist?(imagePath) then
			isSound = soundPath && File.exist?(soundPath)
			exec_cmd = "ffmpeg -loop 1 -framerate 15 -i #{Shellwords.escape(imagePath)}"
			if isSound then
				exec_cmd += " -itsoffset #{fadeInDuration}" if addCrossFadeDuration
				exec_cmd += " -i #{Shellwords.escape(soundPath)}"
			end
			exec_cmd += ( useVideoToolBox ? " -c:v h264_videotoolbox -b:v 10M" : "" )
			exec_cmd += " -tune stillimage -crf 51 #{isSound ? "-c:a aac" : ""} -shortest -strict -2"
			exec_cmd += " -t #{(duration ? duration : 0) + (addCrossFadeDuration ? (fadeInDuration * 2) : 0.0)}" if duration
			if isSound then
				exec_cmd += " -af 'adelay=#{fadeInDuration*1000}|all=1'" if addCrossFadeDuration
				exec_cmd += " -af 'apad=pad_dur=#{fadeInDuration}'" if addCrossFadeDuration
			end
			exec_cmd += " #{options}" if options!=nil
			exec_cmd += " #{outputPath}"

			ExecUtil.execCmd( exec_cmd, FileUtil.getDirectoryFromPath(outputPath) )
		end
	end
end

options = {
	:slides => ".",
	:slideType => "\.png$",
	:sound => ".",
	:soundType => "\.wav$",
	:output => ".",
	:minDuration => nil,
	:fadeInDuration => 0.5,
	:addCrossFadeDuration => false,
	:useToolBox => false,
	:pages => nil
}

opt_parser = OptionParser.new do |opts|
	opts.banner = "Usage: "

	opts.on("-s", "--slides=", "Set slide (.png) path (default:#{options[:slides]})") do |slides|
		options[:slides] = slides.to_s
	end

	opts.on("-v", "--sound=", "Set sound (.wav) path (default:#{options[:sound]}). Set \"\" if no voice") do |sound|
		options[:sound] = sound.to_s
	end

	opts.on("-o", "--output=", "Set output .mp4 path (default:#{options[:output]})") do |output|
		options[:output] = output.to_s
	end

	opts.on("-m", "--minDuration=", "Set minimum duration if necessary (default:#{options[:minDuration]})") do |minDuration|
		options[:minDuration] = minDuration.to_f
	end

	opts.on("-a", "--addSilentDuration=", "Set silent duration for fadeInDuration and CrossFadeDuration. if necessary") do |addSilentDuration|
		options[:fadeInDuration] = addSilentDuration.to_f
		options[:addCrossFadeDuration] = (options[:fadeInDuration]!=0)
	end

	opts.on("-f", "--fadeInDuration=", "Set fade-in duration if necessary") do |fadeInDuration|
		options[:fadeInDuration] = fadeInDuration.to_f
	end

	opts.on("-c", "--crossFadeDuration=", "Set cross fade duration if necessary") do |crossFadeDuration|
		options[:addCrossFadeDuration] = crossFadeDuration.to_f
	end

	opts.on("-t", "--useToolBox", "Set if use toolbox (hwenc) for MacOS X (default:#{options[:useToolBox]})") do
		options[:useToolBox] = true
	end

	opts.on("-p", "--pages=", "Set pages e.g. 5-7 or 5- or 5") do |pages|
		options[:pages] = pages
	end

end.parse!

FileUtil.ensureDirectory(options[:output])
isNoVoice = options[:sound] == "" ? true : false

slideFiles = []
FileUtil.iteratePath( options[:slides], options[:slideType], slideFiles, false, false, 1 )
slideFiles.sort!

soundFiles = []
if !isNoVoice then
	FileUtil.iteratePath( options[:sound], options[:soundType], soundFiles, false, false, 1 )
	soundFiles.sort!
else
	slideFiles.each do |aFile|
		soundFiles << nil
	end
end

durations = []
soundFiles.each do |aSound|
	durations << ( isNoVoice ? options[:minDuration] : Converter.getDuration(aSound, options[:minDuration]) )
end

minSize = [slideFiles.length, soundFiles.length, durations.length].min
slideFiles.slice!(minSize..-1)
soundFiles.slice!(minSize..-1)
durations.slice!(minSize..-1)

startPage = nil
endPage = nil
if options[:pages] then
	if options[:pages].include?("-") then
		pages = options[:pages].split("-")
		startPage = pages[0].to_i
		endPage = (pages.length == 2) ? pages[1].to_i : nil
	else
		startPage = endPage = options[:pages].to_i
	end
end

index = 1
slideFiles.zip(soundFiles, durations).each do |anElement|
	if (startPage == nil) || (index>=startPage && (endPage==nil || index<=endPage)) then
		outputPath = options[:output]+"/"+FileUtil.getFilenameFromPathWithoutExt(anElement[0])+".mp4"
		FileUtils.rm_f(outputPath) if File.exist?(outputPath)
		Converter.convert( anElement[0], anElement[1], outputPath, anElement[2], options[:fadeInDuration], options[:addCrossFadeDuration], options[:useToolBox] )
	end
	index = index + 1
end

