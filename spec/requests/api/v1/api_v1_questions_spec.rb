require 'rails_helper'

RSpec.describe "Api::V1::Questions", type: :request do
  describe "POST /questions" do
    context "with invalid authentication headers" do
      it_behaves_like :deny_without_authorization, :post, "/api/v1/questions"
    end

    context "with valid authentication headers" do
      before do
        @user = create(:user)
      end

      context "and with valid params" do
        before do
          @form = create(:form, user: @user)
          @question_attributes = attributes_for(:question)
          post "/api/v1/questions", params: {question: @question_attributes, form_id: @form.id}, headers: header_with_authentication(@user)
        end

        it "returns success status (200)" do
          expect_status(200)
        end

        it "creates question with correct data" do
          @question_attributes.each do |field|
            expect(Question.first[field.first]).to eql(field.last)
          end
        end

        it "returns correct question data" do
          @question_attributes.each do |field|
            expect(json[field.first.to_s]).to eql(field.last)
          end
        end
      end

      context "with invalid params" do
        before do
          @other_user = create(:user)
        end

        context "and form is valid" do
          before do
            @form = create(:form, user: @user)
          end

          it "returns bad request status (400)" do
            post "/api/v1/questions", params: {question: {}, form_id: @form.id}, headers: header_with_authentication(@user)            
            expect_status(400)
          end
        end

        context "and form is invalid" do
          it "returns bad request status (400)" do
            post "/api/v1/questions", params: {question: {}}, headers: header_with_authentication(@user)            
            expect_status(404)
          end
        end
      end
    end
  end

  describe "PUT /questions/:id" do

    context "with invalid authentication headers" do
      it_behaves_like :deny_without_authorization, :put, "/api/v1/questions/0"
    end

    context "with valid authentication headers" do
      before do
        @user = create(:user)
      end

      context "when question exists" do

        context "and user is the question owner" do
          before do
            @form = create(:form, user: @user)
            @question = create(:question, form: @form)
            @question_attributes = attributes_for(:question, id: @question.id)
            put "/api/v1/questions/#{@question.id}", params: {question: @question_attributes}, headers: header_with_authentication(@user)
          end

          it "returns success status (200)" do
            expect_status(200)
          end

          it "updates question with correct data" do
            @question.reload
            @question_attributes.each do |field|
              expect(@question[field.first]).to eql(field.last)
            end
          end

          it "returns correct question data" do
            @question_attributes.each do |field|
              expect(json[field.first.to_s]).to eql(field.last)
            end
          end
        end

        context "and user is not the owner" do
          before do
            @question = create(:question)
            @question_attributes = attributes_for(:question, id: @question.id)
            put "/api/v1/questions/#{@question.id}", params: {question: @question_attributes}, headers: header_with_authentication(@user)
          end

          it "returns forbidden status (403)" do
            expect_status(403)
          end
        end
      end

      context "when question doesn't exist" do
        before do
          @question_attributes = attributes_for(:question)
        end

        it "returns not found status (404)" do
          delete "/api/v1/questions/0", params: {question: @question_attributes}, headers: header_with_authentication(@user)
          expect_status(404)
        end
      end
    end
  end

  describe "DELETE /questions/:id" do
    before do
      @user = create(:user)
    end

    context "with invalid authentication headers" do
      it_behaves_like :deny_without_authorization, :delete, "/api/v1/questions/0"
    end

    context "with valid authentication headers" do

      context "when question exists" do

        context "and user is the question owner" do
          before do
            @form = create(:form, user: @user)
            @question = create(:question, form: @form)
            delete "/api/v1/questions/#{@question.id}", params: {}, headers: header_with_authentication(@user)
          end

          it "returns success status (200)" do
            expect_status(200)
          end

          it "deletes the question" do
            expect(Question.all.count).to eql(0)
          end
        end

        context "and user is not the owner" do
          before do
            @question = create(:question)
            delete "/api/v1/questions/#{@question.id}", params: {}, headers: header_with_authentication(@user)
          end

          it "returns forbidden status (403)" do
            expect_status(403)
          end
        end
      end

      context "when question doesn't exist" do
        it "returns not found status (404)" do
          delete "/api/v1/questions/0", params: {}, headers: header_with_authentication(@user)
          expect_status(404)
        end
      end
    end
  end
end
