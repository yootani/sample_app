class StaticPagesController < ApplicationController

  def home
    if signed_in?
      #[micropost Instance] alert 'forgot SinedIn test'
      @micropost = current_user.microposts.build if signed_in?
      #[feed Instance]
      @feed_items = current_user.feed.paginate(page: params[:page])
    end
  end

  def help
  end

  def about
  end

  def contact
  end
end
