require 'yaml'

namespace :db do
  desc "Loads in one of the seed data tables"
  task :generate_personal_question_csv, [:source] => :environment do |t, args|
  	p "args = #{args}"

    source_file = args[:source]

    unless source_file
      source_file = "#{Rails.root}/db/seed_data/personal_questions_and_answers_raw.yml"
    end

    PERSONAL_QUESTIONS_FILE = "#{Rails.root}/db/seed_data/personal_questions_tmp.csv"
    PERSONAL_QUESTION_ANSWERS_FILE = "#{Rails.root}/db/seed_data/personal_question_answers_tmp.csv"
    
    DELIM = "|"
    QUESTION_ID_INTERVAL = 1
    QUESTION_RANK_INTERVAL = 100
    ANSWER_ID_INTERVAL = 1
    ANSWER_RANK_INTERVAL = 1

    questions_text =""
    answers_text = ""

    yml = YAML.load_file source_file

    personal_questions = yml['personal_questions']
 
#    p "personal_questions = #{personal_questions.inspect}"
    question_id = 0
    answer_id = 0
    question_rank = 0
    num_questions = 0
    num_answers = 0
    personal_questions.each do |item|
    	label = item['label']
    	question = item['question']
    	answers = item['answers']
    	question_id += QUESTION_ID_INTERVAL
    	question_rank += QUESTION_RANK_INTERVAL
    	num_questions += 1

    	q_line = "#{question_id}#{DELIM}#{question_rank}#{DELIM}#{label}#{DELIM}#{question}\n"
    	questions_text << q_line
#    	p "Got an item. label = #{label}, question = #{question}"
#    	p "answers = #{answers.inspect}"
      answer_rank = 0
      answers.each do |ans|
      	answer_id += ANSWER_ID_INTERVAL
      	answer_rank += ANSWER_RANK_INTERVAL
      	num_answers += 1
      	answer_line = "#{answer_id}#{DELIM}#{question_id}#{DELIM}#{ans}#{DELIM}#{answer_rank}\n"
      	answers_text << answer_line
      end
    end

    File.open(PERSONAL_QUESTIONS_FILE, 'w') { |file| file.write(questions_text) }
    File.open(PERSONAL_QUESTION_ANSWERS_FILE, 'w') { |file| file.write(answers_text) }

    p "DONE! Num Questions = #{num_questions}, Num Answers = #{num_answers}"

  end
end
