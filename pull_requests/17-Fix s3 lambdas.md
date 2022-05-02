# Fix s3 lambdas

**ghost** commented *Jun 4, 2018*

Various resources were conditional on skip_zip, but didn't take into account the difference between skip_zip because a local zip file path was passed in and skip_zip because an s3 zip file was specified.  These changes correct the errors resulting from trying to compute a checksum over a non-existent local file.
<br />
***


**ghost** commented *Jun 5, 2018*

https://github.com/gruntwork-io/package-lambda/issues/18
***

**ghost** commented *Jun 8, 2018*

Sorry, I was onboarding a remote team for the last several days and haven’t
had a chance to look up from that. I’ll try to test out your change
tomorrow sometime. If it’s all good, I’ll update the branch and comment so
you can merge the pull request.

On Thu, Jun 7, 2018 at 19:12 Yevgeniy Brikman <notifications@github.com>
wrote:

> *@brikis98* commented on this pull request.
> ------------------------------
>
> In modules/lambda/main.tf
> <https://github.com/gruntwork-io/package-lambda/pull/17#discussion_r193936781>
> :
>
> >    template = "${base64sha256(file(var.source_path))}"
>  }
>
>  data "template_file" "source_code_hash" {
> -  template = "${var.skip_zip ? join(",", data.template_file.hash_from_source_code_zip.*.rendered) : join(",", data.archive_file.source_code.*.output_base64sha256)}"
> +  template = "${length(var.source_path) == 0 ? "" : var.skip_zip ? join(",", data.template_file.hash_from_source_code_zip.*.rendered) : join(",", data.archive_file.source_code.*.output_base64sha256)}"
>
> I would undo this change. I think the only necessary one is the check you
> added in hash_from_source_code_zip.
>
> —
> You are receiving this because you authored the thread.
> Reply to this email directly, view it on GitHub
> <https://github.com/gruntwork-io/package-lambda/pull/17#discussion_r193936781>,
> or mute the thread
> <https://github.com/notifications/unsubscribe-auth/AdYOqLQoering2m28qwPBg_YaA4w896Wks5t6d2GgaJpZM4UZ89g>
> .
>

***

**brikis98** commented *Jun 8, 2018*

Sounds good, thx!
***

**yorinasub17** commented *Oct 29, 2021*

Closing this as the OP is no longer available.
***

