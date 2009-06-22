require 'rubygems'
require 'icanhasaudio'

f= "test/mock_data/frozen\ city\ \(no\ tags\).mp3"
raise unless File.exists? f
fin= File.open(f,'rb')

module Audio
  module MPEG
    class Decoder

      def omg(input)
        buf = skip_id3_header(input)

        decode_headers_for(buf)
        while !mp3data.header_parsed?
          decode_headers_for(input.read(100))
        end
        mp3data.nsamp = MP3Data::MAX_U_32_NUM unless mp3data.total_frames > 0
        #wav = WAV::File.new(output)
        #wav.write_header(0x7FFFFFFF, 0, num_channels, in_samplerate) if !@raw
        #native_decode(input, wav)
        #if !@raw && attempt_rewind(wav)
        #  wav.write_header(@wavsize + 44, 0, num_channels, in_samplerate)
        #end
      end
      def zxc
        mp3data
      end

    end
  end
end

m= Audio::MPEG::Decoder.new
m.omg fin
p m.zxc.bitrate
p m.zxc.nsamp
p m.zxc.total_frames
p m.zxc
