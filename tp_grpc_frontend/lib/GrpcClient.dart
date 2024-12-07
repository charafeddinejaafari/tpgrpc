import 'package:grpc/grpc.dart';
import 'generated/compte_grpc.dart';
import 'generated/compte.dart';
class GrpcClient {
  late CompteServiceClient stub;

  GrpcClient() {
    final channel = ClientChannel(
      'localhost',
      port: 9090,
      options: const ChannelOptions(credentials: ChannelCredentials.insecure()),
    );
    stub = CompteServiceClient(channel);
  }
  Future<List<Compte>> fetchAllComptes() async {
    final request = GetAllComptesRequest();
    final response = await stub.allComptes(request);
    return response.comptes;
  }

  Future<Compte> saveCompte(
      String type, double solde, String dateCreation) async {
    final TypeCompte enumType = mapStringToTypeCompte(type);
    final compte = CompteRequest()
      ..type = enumType
      ..solde = solde
      ..dateCreation = dateCreation;
    final request = SaveCompteRequest()..compte = compte;
    final response = await stub.saveCompte(request);
    return response.compte;
  }

  Future<bool> deleteCompte(String id) async {
    final request = DeleteByIdRequest()..id = id;
    final response = await stub.deleteById(request);
    return response.success;
  }

  TypeCompte mapStringToTypeCompte(String type) {
    switch (type) {
      case 'EPARGNE':
        return TypeCompte.EPARGNE;
      default:
        return TypeCompte.COURANT;
    }
  }
}
