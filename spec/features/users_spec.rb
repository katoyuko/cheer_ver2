require 'rails_helper'
require "refile/file_double"

RSpec.feature "Userに関するテスト", type: :feature do
  before do
    @user1 = FactoryBot.create(:user)
    @user2 = FactoryBot.create(:user)
    category_image = Refile::FileDouble.new("dummy", "category.png", content_type: "image/png")
    post_category = FactoryBot.create(:post_category, category_image: category_image)
    expect(FactoryBot.create(:post, user: @user1, post_category: post_category)).to be_valid
    expect(FactoryBot.create(:post, user: @user2, post_category: post_category)).to be_valid
  end
  feature "ログインしていない状態で" do
    feature "以下のページへアクセスした際のリダイレクト先の確認" do
      scenario "ユーザー詳細ページ" do
        visit user_path(@user1)
        expect(page).to have_current_path new_user_session_path
      end

      scenario "ユーザー編集ページ" do
        visit edit_user_path(@user1)
        expect(page).to have_current_path new_user_session_path
      end
    end
  end

  feature "ログインした状態で" do
    before do
      login(@user1)
    end
    feature "表示内容とリンクの確認" do
      scenario "マイページの表示内容とリンク" do
        visit user_path(@user1)
        expect(page).to have_content @user1.name
        expect(page).to have_content @user1.introduction
        expect(page).to have_link "ユーザー情報編集 / その他設定", href: edit_user_path(@user1)

        @user1.posts.each do |post|
          expect(page).to have_link "more ▶︎", href: post_path(post)
          expect(page).to have_content post.post_content
        end
      end

      scenario "マイページでno-imageの画像が表示されているか" do
        visit user_path(@user1)
        expect(page).to have_selector "img"
      end

      scenario "他のuserの詳細ページの表示内容とリンク" do
        visit user_path(@user2)
        expect(page).to have_content @user2.name
        expect(page).to have_content @user2.introduction

        @user2.posts.each do |post|
          expect(page).to have_link "more ▶︎", href: post_path(post)
          expect(page).to have_content post.post_content
        end
      end
    end

    feature "他のuserのeditページ" do
      scenario "ページへアクセスできず、トップにリダイレクトされるか" do
        visit edit_user_path(@user2)
        expect(page).to have_current_path root_path
      end
    end
  end
end