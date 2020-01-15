PGM::Application.routes.draw do
	get '/shop' => redirect('crowdinners.com/donate')
end