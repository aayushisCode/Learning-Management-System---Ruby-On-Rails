
Rails.application.routes.draw do
  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # Authentication
  devise_for :users, controllers: {
    sessions: "users/sessions"
  }

  # ==============================
  # API ROUTES
  # ==============================
  namespace :api do
    # Categories
    resources :categories

  # Courses and nested resources
  resources :courses do
    resources :lessons, only: [:index, :show, :create, :update, :destroy] do
    resources :quizzes, only: [:index, :show]
  end

  resources :quizzes, only: [:index, :show, :create, :update, :destroy]
end

    # Standalone resources
    resources :users
    resources :lessons, only: [ :index, :show, :create, :update, :destroy ]
    resources :quizzes, only: [ :index, :show, :create, :update, :destroy ]
    resources :questions, only: [ :index, :show, :create, :update, :destroy ]

    resources :user_courses, only: [ :index, :show, :create, :update, :destroy ]
    resources :user_quizzes, only: [:destroy]

    # ==============================
    # LESSON PROGRESS
    # ==============================

    resources :user_courses do
      resources :lessons do
        post :navigate_page, on: :member,
            to: "lesson_progresses#navigate_page"
      end
    end

    # get "user_courses/:user_course_id/lessons/:lesson_id/next_page",
    #     to: "lesson_progresses#next_page"

    # get "user_courses/:user_course_id/lessons/:lesson_id/prev_page",
    #     to: "lesson_progresses#prev_page"


    # ==============================
    # QUIZ ATTEMPTS
    # ==============================

    post "user_courses/:user_course_id/quizzes/:quiz_id/start",
         to: "quizzes#start"

    get "user_courses/:user_course_id/quizzes/:quiz_id/report_card",
        to: "quizzes#report_card"

    get "user_quizzes/:id",
        to: "quizzes#attempt"

    post "user_quizzes/:id/answer",
         to: "quizzes#answer"

    post "user_quizzes/:id/submit",
         to: "quizzes#submit"
  end

  # ==============================
  # ADMIN ROUTES
  # ==============================

  namespace :admin do
    root "dashboard#index"

    resources :users
    resources :categories
    resources :courses do
      resources :lessons
      resources :quizzes
    end

    resources :questions
    resources :user_courses
  end
end











































# Rails.application.routes.draw do
#   # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

#   # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
#   # Can be used by load balancers and uptime monitors to verify that the app is live.
#   get "up" => "rails/health#show", as: :rails_health_check

#   # Defines the root path route ("/")
#   # root "posts#index"
#   devise_for :users, controllers: { sessions: "users/sessions" }
#   resources :users
#   resources :categories
#   resources :courses do
#     resources :lessons, only: [ :index, :show, :create, :update, :destroy ]
#     resources :quizzes, only: [ :index, :show, :create, :update, :destroy ]
#   end
#   resources :lessons, only: [ :index, :show, :create, :update, :destroy ]
#   resources :quizzes, only: [ :index, :show, :create, :update, :destroy ]
#   resources :questions, only: [ :index, :show, :create, :update, :destroy ]
#   resources :user_courses, only: [ :index, :show, :create, :update, :destroy ]

#   # ── Lesson progress (learner) ─────────────────────────────────────────────
#   get "user_courses/:user_course_id/lessons/:lesson_id/next_page",
#     to: "lesson_progresses#next_page"
#   get "user_courses/:user_course_id/lessons/:lesson_id/prev_page",
#     to: "lesson_progresses#prev_page"
#   post "user_courses/:user_course_id/lessons/:lesson_id/complete_page",
#       to: "lesson_progresses#complete_page"

#   # ── Quiz attempts (learner) ────────────────────────────────────────────────
#   # Start:   POST /user_courses/:user_course_id/quizzes/:quiz_id/start
#   # Quiz attempts handled by QuizzesController
#   post "user_courses/:user_course_id/quizzes/:quiz_id/start",
#       to: "quizzes#start"

#   get "user_quizzes/:id",
#       to: "quizzes#attempt"

#   post "user_quizzes/:id/answer",
#       to: "quizzes#answer"

#   post "user_quizzes/:id/submit",
#       to: "quizzes#submit"

#   namespace :admin do
#     get "dashboard", to: "dashboard#index"
#   end
# end
