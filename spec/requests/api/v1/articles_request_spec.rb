require "rails_helper"

RSpec.describe "Api::V1::Articles", type: :request do
  describe "GET /articles" do
    subject { get(api_v1_articles_path) }

    before do
      create(:article, updated_at: 1.day.ago)
      create(:article, updated_at: 2.days.ago)
      create(:article, updated_at: 3.days.ago)
    end

    context "正常系" do
      it "記事一覧の表示" do
        subject

        json = JSON.parse(response.body)
        # binding.pry
        expect(json.length).to eq(3)
        expect(response.status).to eq(200)
      end
    end
  end
end
