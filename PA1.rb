require "rexml/document"
#require "JSON"
require 'optparse'
#===================== read argument =====================
$options = {}
OptionParser.new do |opts|
        opts.on("-r")                       { |s| $options[:r] = true }
    opts.on("-i", '-i INPUT', "input ") { |s| $options[:i] = s } # ./queries/origin/query-5.xml
    opts.on("-o", '-o OUTPUT',"output") { |s| $options[:o] = s } # ans
    opts.on("-m", '-m MODEL', "model ") { |s| $options[:m] = s } # ./model-files
    opts.on("-d", '-d NTCIR', "ntcir ") { |s| $options[:d] = s } # /tmp2/CIRB010
end.parse!

pre_ntcir = $options[:d].split("/CIRB010")
pre_ntcir = pre_ntcir[0].to_s
#===================== end read argument =====================

#require "selfpage"
# require_relative "execute_query.rb"
# class Execute_query

#     def initialize
#     end

#     def execute(total_number)
#         query = File.new("./src/bin/querytest")

#         # T_id = Array.new()   #save vocabulary id, use type: string
#         # T_f = Array.new()    #save vocabulary frequency, use type: int
#         docScore = Array.new(total_number,0.0)
#         while text = query.gets do
#             text = (text.to_s).split
#             vocabulary_id = text[0].to_s
#             vocabulary_frequency = text[1].to_f
#             puts vocabulary_id.to_s
#             if vocabulary_id == "0" then
#                 next
#             end
#             # T_id << vocabulary_id
#             # T_f  << vocabulary_frequency
#             router = "./vocTable/"+vocabulary_id
#             if vocFile = File.new(router) then
#                 idf = vocFile.gets
#                 idf = idf.to_f
#                 while vocFile.gets do
#                     voc = (voc.to_s).split
#                     docScore[voc[0].to_i] = vocabulary_frequency * idf * voc[1].to_f * idf + docScore[voc[0].to_i]
#                 end
#             else
#                 next
#             end
#             vocFile.close



#         end

#         ofin = File.open('./ofin',"w")

#         for t in 0 .. 30
#             max = 0
#             flag = 0
#             for tt in 0 .. (i-1) 
#                 if docScore[tt] > max then
#                     max = docScore[tt]
#                     flag = tt
#                 end
#             end
#             puts max
#             ofin << "001 "
#             ofin << flag
#             docScore[flag] = -1 

#         end

#         ofin.close()

    
#     end
# end
class DocTable
	attr_accessor :vHash, :dID, :name, :size, :path

	def initialize(id,name,size)
		@dID = id
        @name= name
		@vHash = Hash.new(0)
        @size = size.to_f
	end
 
    def setHash(id,value)
    	@vHash[ id.to_i ] = value.to_f
    end

    def getHash(id)
    	@vHash[id.to_i]
    end

    def getAllHash
    	@vHash
    end

    def getId
    	@dID
    end

    def getName
        @name
    end

    def getSize
        @size.to_f
    end

    def setPath(path)
        @path = path.to_s
    end

    def getPath
        @path.downcase
    end

end


index = File.new("#{$options[:m]}/inverted-index")
doclist = File.new("#{$options[:m]}/file-list")
docArray = Array.new()
vIDF = Array.new()    # 記錄每個vocabulary的IDF
ofin = Array.new()
i = 0   # total doc number
id = 0  # temp save vocabulary id
df = 0  # temp save vocabulary document frequency
dID = 0   # temp save vocabulary in which documnet id
dTf = 0   # temp sava vocabulary frequency in dID document
totalDocLength = 0.0




while a = doclist.gets do
        path = (a.to_s).split
	    path[0].slice!(".")
        path = pre_ntcir+path[0]
        a = (a.to_s).split("/")
        tempSize = File.size(path)
        totalDocLength = totalDocLength + tempSize
        # router = "./docTable/" + i.to_s	
        # puts router
  #       ofin[i] = File.open(router,"w")
		docArray[i] = DocTable.new(i+1,a[4],tempSize)
        docArray[i].setPath(path)
  #       ofin[i] << a[4]
  #       ofin[i] << "\n"
  #       ofin[i].close
		i = i + 1
end
puts "\e[H\e[2J"
puts "doclist is done..."
doclist.close();
avgdoclen = totalDocLength / i
# text = index.gets
# text = (text.to_s).split
# id = text[0]
# df = text[2]
# vIDF[id.to_i] =  Math.log10( i / df.to_f ) 
# text = index.gets
# text = (text.to_s).split
# dID = text[0]
# dTf = text[1]
# router = "./docTable/" + dID.to_s
# puts dID.to_s
# ofin = File.open(router,"a")
# ofin << 1 
# puts id
# ofin << " "
# ofin << (dTf.to_f * vIDF[id.to_i])
# puts (dTf.to_f * vIDF[id.to_i])
# ofin.close



    while text = index.gets do
    	text = (text.to_s).split
    	#  先消除結合字的term
        j = 0
        df = text[2]
    	while text[0] == id do
            df = text[2]
            j = 0
    		while j < df.to_i do
                text = index.gets
                text = (text.to_s).split
                j = j + 1
            end
            text = index.gets
            text = (text.to_s).split
    	end

    	id = text[0]
        if id == nil then
            break
        end
    	df = text[2]
    	vIDF[id.to_i] =  Math.log10( i / df.to_f ) 
    	j = 0
        puts ("Voc ID : " + id + " is done...")
     
    	#建立Vocabulary的每個doc的term出現的次數
        while j < df.to_i do
        	text = index.gets
            # puts text
        	text = (text.to_s).split
            dID = text[0]
            dTf = text[1]
            # router = "./vocTable/" + id.to_s 
            # ofin[dID.to_i] = File.open(router,"a")
            #Okapi/BM25 k = 1 b = 0.75
            bm25 = (dTf.to_f * vIDF[id.to_i] * 3.0) / (dTf.to_f + 2.0*(1.0-0.75+0.75*docArray[dID.to_i].getSize/avgdoclen))
            docArray[dID.to_i].setHash(id.to_i, bm25  )
          
            j = j + 1
           
        end
  

    end


puts "docArray is done..."

#處理query 將query個別分開 存成一個檔案後 在處理ngram(助教提供的程式)
xml = File.new($options[:i])
doc = REXML::Document.new xml
creat_path = "./query_"
query_num = 0 
doc.elements.each('xml/topic') do |t|
    query_num = query_num+1
    query_ofin = File.new( (creat_path+query_num.to_s) , "w" )
    query_ofin << t
    query_ofin.close
end
    ofin = File.open($options[:o],"w")
    ofin.close
    if $options[:r] == true then
        ofin_feedback = File.open("#{$options[:o]}-feedback","w")
        ofin_feedback.close
    end
system("clear")
puts "query exe is done ..."
total_query = query_num
# 控制正在處理的 query number
query_num = 1 
while File.exist?((creat_path+query_num.to_s)) && !(query_num > total_query) do
    docScore = Array.new(i+1,0)
    topK = Array.new
    docnum = 0
    cmd = "./src/bin/create-ngram -vocab #{$options[:m]}/vocab.all -o query_exe_"+query_num.to_s+" -n 1 -tmp ./tmp -encoding utf8 query_"+query_num.to_s
    system(cmd)
    find_path = "./query_exe_"
    query = File.new((find_path+query_num.to_s))
    while text = query.gets do
        text = (text.to_s).split
       
        id = text[0]
        df = text[1]
        if id.to_i == 0 then
            next
        end
        # puts id
        for t in 0..(i-1)
            docScore[t] = docScore[t] + docArray[t].getHash(id.to_i) * df.to_f * vIDF[id.to_i]
           
        end


    end

    puts ("Query#"+query_num.to_s+" docScore is done...")

    if query_num >= 10 then
        ofin_num = "0"+ query_num.to_s
    else
        ofin_num = "00#{query_num}"
    end
    ofin = File.open("#{$options[:o]}","a")
    max_max = 0;
    for t in 0 .. 50
        max = 0
        flag = 0
        for tt in 0 .. (i-1) 
            if docScore[tt] > max  && (!topK.include?(tt)) then
                max = docScore[tt]
                if max > max_max then
                    max_max = max
                end
                flag = tt
            end
        end
        if (max/max_max) < 0.5 then
            break
        end
        topK << flag
        #puts (max/max_max)
        ofin << ofin_num
        ofin << " "
        ofin << (docArray[flag].getName).downcase 

    end

    ofin.close()
    puts "Query#{query_num} feedback is start..."


    #========================== feedback code is start from here =========================#
  
    if $options[:r] == true then
        
        
            docScore_feedback = Array.new(i+1,0)

            newQuery = DocTable.new(1,1,1)

            for t in 0 .. 4
                 relevant_doc = docArray[topK[t]]
                 # index = 1 
                 cmd = "./src/bin/create-ngram -vocab #{$options[:m]}/vocab.all -o feedback_#{t} -n 1 -tmp ./tmp -encoding utf8 #{relevant_doc.getPath}" 
                 # puts cmd
                 system(cmd)
                 # while (relevant_doc.getHash(index) != nil) && index.to_i <= dID.to_i do
                 #      if(newQuery.getHash(index) > 0 ) then
                 #        newQuery.setHash( index , (newQuery.getHash(index)+ relevant_doc.getHash(index))  )
                 #      else
                 #        newQuery.setHash( index , relevant_doc.getHash(index)  )
                 #      end
                        

            #         puts index
            #         if relevant_doc.getHash(index) > 0 then

            #             rDV_ID = index
            #             rDV_TF = relevant_doc.getHash(index)

                        

            #             for t in 0..(i-1)
            #                 docScore_feedback[t] = docScore_feedback[t] + docArray[t].getHash(rDV_ID.to_i) * rDV_TF
            #                 puts "#{rDV_ID} for while #{t}"
            #             end
            #         end

                     # index = index + 1
                 # end


            end
            cmd = "./src/bin/merge-ngram -o ngram.all -tmp ./tmp feedback_0 feedback_1 feedback_2 feedback_3 feedback_4"
            system(cmd)
            term_number = 0;
            newquery = File.new("ngram.all")
            while text = newquery.gets do
                text = (text.to_s).split
               
                id = text[0]
                if (text[1].to_i < 20 ) then
                    next
                end
                df = 0
                if id.to_i == 0 then
                    next
                end
                for t in 0 .. 4
                 relevant_doc = docArray[topK[t]]
                  df = df + (docArray[topK[t]].getHash(id.to_i)).to_f
                end 
                # puts id
                term_number = term_number + 1
                for t in 0..(i-1)
                    docScore_feedback[t] = docScore_feedback[t] + ( docArray[t].getHash(id.to_i) ).to_f * df.to_f * vIDF[id.to_i] 
                   
                end


            end
            ofin_feedback = File.open("#{$options[:o]}-feedback","a")
            topK_feedback = Array.new
            max_max = 0;
            for t in 0 .. 50
                alpha = 1
                beta = 0.1
                max = 0
                flag = 0
                for tt in 0 .. (i-1) 
                    if (docScore[tt]*alpha + ( docScore_feedback[tt] * beta / 4 ) ) > max  && (!topK_feedback.include?(tt)) then
                        max = (docScore[tt]*alpha + ( docScore_feedback[tt] * beta / 4 ) )
                        if max > max_max then
                            max_max = max
                        end
                        flag = tt
                    end
                end
                if (max/max_max) < 0.55 then
                    break
                end
               # puts (max/max_max)
                topK_feedback << flag

               
                ofin_feedback << ofin_num
                ofin_feedback << " "
                ofin_feedback << (docArray[flag].getName).downcase 

            end

            puts "Query#{query_num} feedback is done..."
            ofin_feedback.close

       
    end
    query_num = query_num + 1 
end
index.close()



puts "Program is done..."

