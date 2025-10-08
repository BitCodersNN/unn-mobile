import 'package:unn_mobile/core/misc/git/git_folder.dart';
import 'package:unn_mobile/core/providers/implementations/common/last_commit_sha_provider_impl.dart';
import 'package:unn_mobile/core/providers/interfaces/loading_page/last_commit_sha_loading_page_provider.dart';

class LastCommitShaLoadingPageProviderImpl extends LastCommitShaProviderImpl
    implements LastCommitShaLoadingPageProvider {
  LastCommitShaLoadingPageProviderImpl(super.storage)
      : super(gitPath: GitPath.loadingScreen);
}
