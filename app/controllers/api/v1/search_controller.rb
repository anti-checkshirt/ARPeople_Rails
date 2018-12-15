require 'net/http'
require 'json'
class Api::V1::SearchController < ApplicationController
    def create_person_group(group_name)
        uri = URI("https://japaneast.api.cognitive.microsoft.com/face/v1.0/persongroups/#{group_name}")
        uri.query = URI.encode_www_form({
        })
        request = Net::HTTP::Put.new(uri.request_uri)
        request['Content-Type'] = 'application/json'
        request['Ocp-Apim-Subscription-Key'] = ENV['AZURE_TOKEN']
        request.body = "{'name': '#{group_name}', 'userData': 'user-provided data attached to the person group.'}"
        response = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
            http.request(request)
        end
        return response.body
    end

    # グループにPersonを登録
    def create_person(person_name)
        uri = URI("https://japaneast.api.cognitive.microsoft.com/face/v1.0/persongroups/ar_people/persons")
        uri.query = URI.encode_www_form({
        })
        request = Net::HTTP::Post.new(uri.request_uri)
        # Request headers
        request['Content-Type'] = 'application/json'
        # Request headers
        request['Ocp-Apim-Subscription-Key'] = ENV['AZURE_TOKEN']
        # Request body
        request.body = "{'name': '#{person_name}'}"
        response = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
            http.request(request)
        end
        
        return JSON.parse(response.body)["personId"]
    end
  
    def add_face(person_id, image_url)
        uri = URI("https://japaneast.api.cognitive.microsoft.com/face/v1.0/persongroups/ar_people/persons/#{person_id}/persistedFaces")
        uri.query = URI.encode_www_form({
            # Request parameters
            'userData' => 'user-provided data attached to the person group.',
        })
        request = Net::HTTP::Post.new(uri.request_uri)
        # Request headers
        request['Content-Type'] = 'application/json'
        # Request headers
        request['Ocp-Apim-Subscription-Key'] = ENV['AZURE_TOKEN']
        # Request body
        request.body = "{'url': '#{image_url}'}"
        response = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
            http.request(request)
        end
  
        return response.body
    end
  
    def train()
        uri = URI("https://japaneast.api.cognitive.microsoft.com/face/v1.0/persongroups/ar_people/train")
        uri.query = URI.encode_www_form({
        })
        request = Net::HTTP::Post.new(uri.request_uri)
        # Request headers
        request['Ocp-Apim-Subscription-Key'] = ENV['AZURE_TOKEN']
        response = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
            http.request(request)
        end
        return response.body
    end
  
    def detect_face(image_url)
        uri = URI('https://japaneast.api.cognitive.microsoft.com/face/v1.0/detect')
        uri.query = URI.encode_www_form({
            # Request parameters
            'returnFaceId' => 'true',
            'returnFaceLandmarks' => 'false',
        })
        request = Net::HTTP::Post.new(uri.request_uri)
        # Request headers
        request['Content-Type'] = 'application/json'
        # Request headers
        request['Ocp-Apim-Subscription-Key'] = ENV['AZURE_TOKEN']
        # Request body
        request.body = "{'url': '#{image_url}'}"
        response = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
            http.request(request)
        end
        p JSON.parse(response.body)
        return JSON.parse(response.body)[0]["faceId"]
    end

    def identify_person(detected_faceId)
        uri = URI('https://japaneast.api.cognitive.microsoft.com/face/v1.0/identify')
        uri.query = URI.encode_www_form({
        })
        
        request = Net::HTTP::Post.new(uri.request_uri)
        # Request headers
        request['Content-Type'] = 'application/json'
        # Request headers
        request['Ocp-Apim-Subscription-Key'] = ENV['AZURE_TOKEN']
        # Request body
        request.body = "{'personGroupId': 'ar_people', 'faceIds': ['#{detected_faceId}'], 'maxNumOfCandidatesReturned': 1, 'confidenceThreshold': 0.5 }"
        p request.body
        response = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
            http.request(request)
        end
        return JSON.parse(response.body)
    end

    def get_name_by_person_id(person_id)
        uri = URI("https://japaneast.api.cognitive.microsoft.com/face/v1.0/persongroups/ar_people/persons/#{person_id}")
        uri.query = URI.encode_www_form({
        })
        request = Net::HTTP::Get.new(uri.request_uri)
        # Request headers
        request['Ocp-Apim-Subscription-Key'] = ENV['AZURE_TOKEN']
        # Request body
        response = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
            http.request(request)
        end
        
        puts response.body
    end
    
    def show
      person_id = create_person(params[:person_name])
      image_file_names = []
      dir = Dir.open("public/#{params[:id]}")
      dir.each do  |filenames|
        image_file_names = dir
      end
      image_file_names.each do |image_file_name|
        add_face(person_id, image_file_names)
      end
      train()
    end
end