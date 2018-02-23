require 'rails_helper'

RSpec.describe "Api::V1::Answers", type: :request do
  describe "GET /answers" do
    context "with invalid authentication headers" do
      it_behaves_like :deny_without_authorization, :get, "/api/v1/answers"
    end

    context "with valid authentication headers" do
      before do
        @user = create(:user)
        @form = create(:form, user: @user)
        @answer1 = create(:answer, form: @form)
        @answer2 = create(:answer, form: @form)

        get "/api/v1/answers", params: {form_id: @form.id}, headers: header_with_authentication(@user)
      end

      it "returns success status (200)" do
        expect_status(200)
      end

      it "returns form list with 2 answers" do
        expect(json.count).to eql(2)
      end

      it "returns answers with correct data" do
        expect(json[0]).to eql(JSON.parse(@answer1.to_json))
        expect(json[1]).to eql(JSON.parse(@answer2.to_json))
      end
    end
  end

  describe "GET /answers/:id" do
    context "with invalid authentication headers" do
      it_behaves_like :deny_without_authorization, :get, "/api/v1/answers/0"
    end

    context "with valid authentication headers" do
      before do
        @user = create(:user)
        @form = create(:form, user: @user)
      end

      context "when answer exists" do
        before do
          @answer = create(:answer, form: @form)
          @questions_answers_1 = create(:questions_answer, answer: @answer)
          @questions_answers_2 = create(:questions_answer, answer: @answer)
          
          get "/api/v1/answers/#{@answer.id}", params: {}, headers: header_with_authentication(@user)
        end

        it "returns success status (200)" do
          expect_status(200)
        end

        it "returns answer with correct data" do
          expect(json.except("questions_answers")).to eql(JSON.parse(@answer.to_json))
        end

        it "returns associated questions_answers" do
          expect(json['questions_answers'].first).to eql(JSON.parse(@questions_answers_1.to_json))
          expect(json['questions_answers'].last).to eql(JSON.parse(@questions_answers_2.to_json))
        end
      end

      context "when answer doesn't exist" do
        it "returns not found status (404)" do
          get "/api/v1/answers/#{FFaker::Lorem.word}", params: {}, headers: header_with_authentication(@user)
          expect_status(404)
        end
      end
    end
  end

  describe "POST /answers" do
    context "with invalid authentication headers" do
      it_behaves_like :deny_without_authorization, :post, "/api/v1/answers"
    end

    context "with valid authentication headers" do
      context "and with valid form id" do
        before do
          @user = create(:user)
          @form = create(:form, user: @user)       
          @question = create(:question, form: @form)
          @questions_answers_1_attributes = attributes_for(:questions_answer, question_id: @question.id)  
          @questions_answers_2_attributes = attributes_for(:questions_answer, question_id: @question.id)

          post "/api/v1/answers", params: {form_id: @form.id, questions_answers: [@questions_answers_1_attributes, @questions_answers_2_attributes]}, headers: header_with_authentication(@user)
        end

        it "returns success status (200)" do
          expect_status(200)
        end

        it "associates answer with the correct form" do
          expect(@form).to eql(Answer.last.form)
        end

        it "associates questions_answers to the answer" do
          expect(json["id"]).to eql(QuestionsAnswer.first.answer.id)
          expect(json["id"]).to eql(QuestionsAnswer.last.answer.id)          
        end
      end

      context "and with invalid form id" do
        before do
          @other_user = create(:user)
          post "/api/v1/answers", params: {form_id: 0}, headers: header_with_authentication(@user)
        end

        it "returns not found status (404)" do
          expect_status(404)
        end
      end
    end
  end

  describe "DELETE /answers/:id" do
    context "with invalid authentication headers" do
      it_behaves_like :deny_without_authorization, :delete, "/api/v1/answers/questionary"
    end

    context "with valid authentication headers" do
      before do
        @user = create(:user)
        @form = create(:form, user: @user)     
      end

      context "when answer exists" do
        context "and user is the form owner" do
          before do
            @answer = create(:answer, form: @form)
            @questions_answers = create(:questions_answer, answer: @answer)
            
            delete "/api/v1/answers/#{@answer.id}", params: {}, headers: header_with_authentication(@user)
          end

          it "returns success status (200)" do
            expect_status(200)
          end

          it "deletes the answer" do
            expect(Answer.all.count).to eql(0)
          end

          it "deletes associated questions_answers" do
            expect(QuestionsAnswer.all.count).to eql(0)
          end
        end

        context "and user is not the form owner" do
          before do
            @answer = create(:answer)
            delete "/api/v1/answers/#{@answer.id}", params: {}, headers: header_with_authentication(@user)
          end

          it "returns forbidden status (403)" do
            expect_status(403)
          end
        end
      end

      context "when answer doesn't exist" do
        it "returns not found status (404)" do
          delete "/api/v1/answers/#{FFaker::Lorem.word}", params: {}, headers: header_with_authentication(@user)
          expect_status(404)
        end
      end
    end
  end
end
