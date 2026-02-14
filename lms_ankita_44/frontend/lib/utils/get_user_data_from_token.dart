import 'package:jwt_decode/jwt_decode.dart';
import '../models/user.dart';

User getUserDataFromToken(String token) {
  final decoded = Jwt.parseJwt(token);

  return User(
    id: decoded['_id'],
    name: decoded['name'],
    username: decoded['username'],
    email: decoded['email'],
    userType: decoded['userType'],
  );
}
