import 'package:flutter/material.dart';
import 'package:ve_xem_phim/models/movie.dart';

const List<Movie> nowShowingMovies = [
  Movie(
    title: 'Avengers: Secret Wars',
    genre: 'Hành động • Sci-Fi',
    rating: '9.2',
    duration: '180 phút',
    year: '2026',
    colors: [Color(0xFF1A237E), Color(0xFF880E4F)],
    posterUrl:
        'https://image.tmdb.org/t/p/w780/7RyHsO4yDXtBv1zUU3mTpHeQ0d5.jpg',
    firstShowing: '01/05/2026',
    language: 'Tiếng Anh (Phụ đề Việt)',
    ageRating: 'T13',
    ageRatingDesc: 'Phim được phổ biến đến người xem từ đủ 13 tuổi trở lên.',
    director: 'Anthony & Joe Russo',
    cast: [
      'Robert Downey Jr.',
      'Chris Evans',
      'Scarlett Johansson',
      'Benedict Cumberbatch',
      'Tom Holland',
    ],
    description:
        'Sau sự kiện Endgame, vũ trụ Marvel bước vào kỷ nguyên mới khi các dị nhân bắt đầu xâm chiếm Trái Đất từ đa vũ trụ. Các Avengers buộc phải tập hợp lại một lần nữa để đối mặt với mối đe dọa lớn nhất từ trước đến nay — Secret Wars, cuộc chiến bí mật định đoạt số phận của toàn bộ đa vũ trụ.',
  ),
  Movie(
    title: 'Mission: Impossible 8',
    genre: 'Hành động • Gián điệp',
    rating: '8.9',
    duration: '155 phút',
    year: '2026',
    colors: [Color(0xFF4E342E), Color(0xFF37474F)],
    posterUrl:
        'https://image.tmdb.org/t/p/w780/z53D72EAOxGRqdr7KXXWp9dJiDe.jpg',
    firstShowing: '22/05/2026',
    language: 'Tiếng Anh (Phụ đề Việt)',
    ageRating: 'T16',
    ageRatingDesc: 'Phim được phổ biến đến người xem từ đủ 16 tuổi trở lên.',
    director: 'Christopher McQuarrie',
    cast: [
      'Tom Cruise',
      'Hayley Atwell',
      'Ving Rhames',
      'Simon Pegg',
      'Rebecca Ferguson',
    ],
    description:
        'Ethan Hunt và đội IMF phải ngăn chặn một tổ chức khủng bố bí ẩn có trong tay vũ khí có thể kiểm soát toàn bộ hệ thống tình báo thế giới. Nhiệm vụ lần này không chỉ là sống còn — mà là quyết định ai sẽ kiểm soát tương lai của nhân loại.',
  ),
  Movie(
    title: 'Inside Out 3',
    genre: 'Hoạt hình • Gia đình',
    rating: '8.5',
    duration: '110 phút',
    year: '2026',
    colors: [Color(0xFF4A148C), Color(0xFF0D47A1)],
    posterUrl:
        'https://image.tmdb.org/t/p/w780/2H1TmgdfNtsKlU9jKdeNyYL5y8T.jpg',
    firstShowing: '13/06/2026',
    language: 'Tiếng Anh • Tiếng Việt (lồng tiếng)',
    ageRating: 'P',
    ageRatingDesc: 'Phim được phổ biến đến mọi đối tượng khán giả.',
    director: 'Kelsey Mann',
    cast: [
      'Amy Poehler',
      'Maya Hawke',
      'Kensington Tallman',
      'Tony Hale',
      'Liza Lapira',
    ],
    description:
        'Riley giờ đã vào đại học, mang theo cả thế giới cảm xúc bên trong. Khi những cảm xúc mới xuất hiện, Joy, Sadness và những người bạn phải tìm cách giúp Riley vượt qua giai đoạn trưởng thành đầy thử thách và khám phá ra ý nghĩa thật sự của việc là chính mình.',
  ),
  Movie(
    title: 'Moana 3',
    genre: 'Hoạt hình • Phiêu lưu',
    rating: '8.7',
    duration: '115 phút',
    year: '2026',
    colors: [Color(0xFF006064), Color(0xFF1B5E20)],
    posterUrl:
        'https://image.tmdb.org/t/p/w780/aLVkiINlIeCkcZIzb7XHzPYgO6L.jpg',
    firstShowing: '25/06/2026',
    language: 'Tiếng Anh • Tiếng Việt (lồng tiếng)',
    ageRating: 'P',
    ageRatingDesc: 'Phim được phổ biến đến mọi đối tượng khán giả.',
    director: 'Dana Ledoux Miller',
    cast: [
      'Auli\'i Cravalho',
      'Dwayne Johnson',
      'Alan Tudyk',
      'Rachel House',
      'Temuera Morrison',
    ],
    description:
        'Moana trở lại với hành trình vĩ đại hơn bao giờ hết — vượt ra ngoài đại dương quen thuộc để khám phá những vùng đất huyền bí chưa từng được ghi chép. Cùng Maui và những người bạn mới, cô phải đối mặt với một bí ẩn cổ xưa đe dọa sự cân bằng của thế giới.',
  ),
];

const List<Movie> comingSoonMovies = [
  Movie(
    title: 'Jurassic World 4',
    genre: 'Phiêu lưu • Viễn tưởng',
    rating: 'Sắp ra mắt',
    duration: '~140 phút',
    year: '2026',
    colors: [Color(0xFF1B5E20), Color(0xFF004D40)],
    posterUrl:
        'https://image.tmdb.org/t/p/w780/q0fGCmjLu42MPlSO9OYWpI5w86I.jpg',
    firstShowing: 'Mùa hè 2026',
    language: 'Tiếng Anh (Phụ đề Việt)',
    ageRating: 'T13',
    ageRatingDesc: 'Phim được phổ biến đến người xem từ đủ 13 tuổi trở lên.',
    director: 'Gareth Edwards',
    cast: [
      'Scarlett Johansson',
      'Jonathan Bailey',
      'Manuel Garcia-Rulfo',
      'Rupert Friend',
    ],
    description:
        'Bốn mươi năm sau sự cố tại Jurassic Park, khủng long không còn bị giới hạn trong hòn đảo nữa. Chúng đã lan ra toàn thế giới và trở thành một phần không thể tách rời của hệ sinh thái. Nhưng khi một loài mới — hung hãn và thông minh hơn bất kỳ loài nào từng tồn tại — xuất hiện, nhân loại đứng trước ngưỡng cửa tuyệt chủng.',
  ),
  Movie(
    title: 'Spider-Man: Beyond',
    genre: 'Siêu anh hùng • Hành động',
    rating: 'Sắp ra mắt',
    duration: '~135 phút',
    year: '2026',
    colors: [Color(0xFFB71C1C), Color(0xFF1A237E)],
    posterUrl:
        'https://image.tmdb.org/t/p/w780/5weKu49pzJCt06OPpjvT80efnQj.jpg',
    firstShowing: 'Cuối năm 2026',
    language: 'Tiếng Anh (Phụ đề Việt)',
    ageRating: 'T13',
    ageRatingDesc: 'Phim được phổ biến đến người xem từ đủ 13 tuổi trở lên.',
    director: 'Destin Daniel Cretton',
    cast: [
      'Tom Holland',
      'Zendaya',
      'Benedict Cumberbatch',
      'Andrew Garfield',
      'Tobey Maguire',
    ],
    description:
        'Peter Parker phải đối mặt với kẻ thù nguy hiểm nhất từ trước đến nay khi đa vũ trụ một lần nữa bị xé toạc. Ba thế hệ Spider-Man cùng đứng chung chiến tuyến trong trận chiến cuối cùng để bảo vệ những người họ yêu thương.',
  ),
  Movie(
    title: 'Transformers: Rise',
    genre: 'Hành động • Sci-Fi',
    rating: 'Sắp ra mắt',
    duration: '~150 phút',
    year: '2027',
    colors: [Color(0xFF0D47A1), Color(0xFF311B92)],
    posterUrl:
        'https://image.tmdb.org/t/p/w780/gPbM0MK8CP8A174rmUwGsADNYKD.jpg',
    firstShowing: 'Đầu năm 2027',
    language: 'Tiếng Anh (Phụ đề Việt)',
    ageRating: 'T16',
    ageRatingDesc: 'Phim được phổ biến đến người xem từ đủ 16 tuổi trở lên.',
    director: 'Steven Caple Jr.',
    cast: [
      'Anthony Ramos',
      'Dominique Fishback',
      'Peter Cullen',
      'Ron Perlman',
    ],
    description:
        'Autobots và Decepticons không còn là mối đe dọa duy nhất. Một thế lực cổ đại từ ngoài vũ trụ đang tiến về Trái Đất — và lần này, cả hai phe phải liên minh để đối mặt với kẻ thù chung có thể xóa sổ nền văn minh.',
  ),
];
