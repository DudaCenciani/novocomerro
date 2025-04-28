import 'visita_model.dart';

class VisitaStorage {
  static final List<Visita> visitas = [];
  static final List<Observacao> observacoes = [];

  static void adicionarVisita(Visita visita) {
    visitas.add(visita);
  }

  static void adicionarObservacao(Observacao observacao) {
    observacoes.add(observacao);
  }
}
