#  Copyright (C) 2021, 2022 hidenorly
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

class StrUtil
	def self.ensureUtf8(str, replaceChr="_")
		str = str.to_s
		str.encode!("UTF-8", :invalid=>:replace, :undef=>:replace, :replace=>replaceChr) if !str.valid_encoding?
		return str
	end

=begin
	theStr= "(abc(def(g(h)())))"
	puts "0:"+StrUtil.getBlacket(theStr, "(", ")", 0)
	puts "1:"+StrUtil.getBlacket(theStr, "(", ")", 1)
	puts "4:"+StrUtil.getBlacket(theStr, "(", ")", 4)
	puts "5:"+StrUtil.getBlacket(theStr, "(", ")", 5)
	puts "9:"+StrUtil.getBlacket(theStr, "(", ")", 9)
	exit(0)
=end
	def self.getBlacket(theStr, blacketBegin="(", blacketEnd=")", startPos=0)
		theLength = theStr.length
		blacketLength = [blacketBegin.length.to_i, blacketEnd.length.to_i].max
		result = theStr.slice(startPos, theLength-startPos)

		pos = theStr.index(blacketBegin, startPos)
		nCnt = pos ? 1 : 0
		target_pos1 = pos ? pos : startPos
		target_pos2 = nil

		while pos!=nil && pos<theLength && nCnt>0
			pos = pos + 1
			theChr = theStr.slice(pos, blacketLength)
			if theChr.start_with?(blacketBegin) then
				nCnt = nCnt + 1
			else
				pos2 = theChr.index(blacketEnd)
				if pos2 then
					nCnt = nCnt - 1
					target_pos2 = pos + pos2
				end
			end
		end

		if target_pos1 && target_pos2 && target_pos2>target_pos1 then
			result = theStr.slice( target_pos1 + blacketBegin.length, target_pos2 - target_pos1 - blacketEnd.length )
		end

		return result
	end

	DEF_SEPARATOR_CONDITIONS=[
		" ",
		"{",
		"}",
		",",
		"[",
		"]",
		"\"",
		" ",
		":"
	]

	def getJsonKey(body, curPos = 0 , lastFound)
		identifier = ":"
		result = body
		pos = body.index(identifier, curPos)
		searchLimit = lastFound ? pos-lastFound : pos
		lastFound = lastFound ? lastFound : 0
		foundPos = nil
		if pos then
			for i in 1..searchLimit do
				theTarget = body.slice(pos-i)
				DEF_SEPARATOR_CONDITIONS.each do |aCondition|
					if theTarget == aCondition then
						foundPos = pos - i
						break
					end
				end
=begin
				if body.slice(pos-i).match(/( |\"|\'|\[|\]|,'|{|})/) then
					foundPos = pos-i
					break
				end
=end
			break if foundPos
			end
		end
		if foundPos then
			result = body.slice(lastFound, foundPos-lastFound) + "\"" + body.slice(foundPos+1,pos-foundPos-1) + "\""
		else
			result = body.slice(lastFound, curPos-lastFound)
		end
		return result
	end

	def ensureJson(body)
		return "{ #{body} }".gsub(/(\w+)\s*:/, '"\1":').gsub(/,(?= *\])/, '').gsub(/,(?= *\})/, '')

		result = ""
		i = 0
		lastFound = nil
		theLength = body.length
		pos = body.index(":", i)
		while i<theLength && pos!=nil
			pos = body.index(":", i)
			if pos then
				i = pos + 1
				result = result + getJsonKey(body, pos, lastFound) + ":"
				lastFound = i
			else
				result = result + body.slice(i, theLength)
				break
			end
		end
		result = body if result.empty?
		return result
	end
end
