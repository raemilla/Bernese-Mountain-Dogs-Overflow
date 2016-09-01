get '/questions/:id/answers/new' do
  @question= Question.find(params[:id])
  if current_user && current_user.id != @question.user_id
    if request.xhr?
      erb :'/answers/create', layout: false
    else
      erb :'/answers/create'
    end
  elsif current_user
    redirect '/questions'
  else
    redirect 'users/login'
  end
end

post '/answers' do
  answer=Answer.new(params[:answer])
  question=Question.find(answer.question_id)
  if answer.save
    redirect "/questions/#{question.id}"
  else
    @error=answer.errors.full_messages
    erb :'/answers/create'
  end
end

get '/answers/:id/edit' do
  require_user
  @answer= Answer.find(params[:id])
  erb :'/answers/edit'
end

get '/answers/:id/upvote' do
  require_user
  question_id= Answer.find(params[:id]).question.id
  vote= Vote.create(user_id: current_user.id, value: 1, votable_type: "Answer", votable_id: params[:id])
  redirect "/questions/#{question_id}"
end

get '/answers/:id/downvote' do
  require_user
  question_id= Answer.find(params[:id]).question.id
  vote= Vote.create(user_id: current_user.id, value: -1, votable_type: "Answer", votable_id: params[:id])
  redirect "/questions/#{question_id}"
end

put '/answers/:id' do
  halt(404, erb(:'404')) unless login?

  @answer = Answer.find(params[:id])
  @answer.assign_attributes(params[:answer])

  if @answer.save
    redirect "questions/#{@answer.question_id}"
  else
    @errors = @answer.errors.full_messages
    erb :'answers/edit'
  end
end

delete '/answers/:id' do
  require_user
  @answer = Answer.find(params[:id])
  @answer.destroy
  redirect "/questions/#{@answer.question_id}"
end

get '/answers/:id/best' do
  require_user
  @answer = Answer.find(params[:id])
  @question = Question.find(@answer.question_id)
  question_answers = @question.answers
  best_values = question_answers.map { |answer| answer.best }

  if current_user.id == @question.user_id
    if best_values.exclude?(true)
      @answer.best = true
        if @answer.save
          redirect "/questions/#{@answer.question_id}"
        end
    end
  else
    @errors = ["Could not mark as best answer"]
  end

end


