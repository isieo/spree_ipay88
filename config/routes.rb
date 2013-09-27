Spree::Core::Engine.routes.draw do
  # Add your extension routes here
  resources :orders do
    resource :checkout, :controller => 'checkout' do
      member do
        get :ipay88_proxy
        get :ipay88_cancel
        get :ipay88_return
      end
    end
  end

  post '/ipay88' => 'ipay88_status#update'
end
