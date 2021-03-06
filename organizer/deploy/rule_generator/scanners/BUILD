# Rule generators for each Forseti scanner.
package(default_visibility = ["//visibility:public"])

licenses(["notice"])  # Apache 2.0

py_library(
    name = "base_scanner_rules",
    srcs = ["base_scanner_rules.py"],
)

py_library(
    name = "audit_logging_scanner_rules",
    srcs = ["audit_logging_scanner_rules.py"],
    deps = [":base_scanner_rules"],
)

py_test(
    name = "audit_logging_scanner_rules_test",
    srcs = ["audit_logging_scanner_rules_test.py"],
    python_version = "PY3",
    deps = [
        ":audit_logging_scanner_rules",
        ":scanner_test_utils",
    ],
)

py_library(
    name = "bigquery_scanner_rules",
    srcs = ["bigquery_scanner_rules.py"],
    deps = [":base_scanner_rules"],
)

py_test(
    name = "bigquery_scanner_rules_test",
    srcs = ["bigquery_scanner_rules_test.py"],
    python_version = "PY3",
    deps = [
        ":bigquery_scanner_rules",
        ":scanner_test_utils",
    ],
)

py_library(
    name = "bucket_scanner_rules",
    srcs = ["bucket_scanner_rules.py"],
    deps = [":base_scanner_rules"],
)

py_test(
    name = "bucket_scanner_rules_test",
    srcs = ["bucket_scanner_rules_test.py"],
    python_version = "PY3",
    deps = [
        ":bucket_scanner_rules",
        ":scanner_test_utils",
    ],
)

py_library(
    name = "cloudsql_scanner_rules",
    srcs = ["cloudsql_scanner_rules.py"],
    deps = [":base_scanner_rules"],
)

py_test(
    name = "cloudsql_scanner_rules_test",
    srcs = ["cloudsql_scanner_rules_test.py"],
    python_version = "PY3",
    deps = [
        ":cloudsql_scanner_rules",
        ":scanner_test_utils",
    ],
)

py_library(
    name = "enabled_apis_scanner_rules",
    srcs = ["enabled_apis_scanner_rules.py"],
    deps = [":base_scanner_rules"],
)

py_test(
    name = "enabled_apis_scanner_rules_test",
    srcs = ["enabled_apis_scanner_rules_test.py"],
    python_version = "PY3",
    deps = [
        ":enabled_apis_scanner_rules",
        ":scanner_test_utils",
    ],
)

py_library(
    name = "iam_scanner_rules",
    srcs = ["iam_scanner_rules.py"],
    deps = [":base_scanner_rules"],
)

py_test(
    name = "iam_scanner_rules_test",
    srcs = ["iam_scanner_rules_test.py"],
    python_version = "PY3",
    deps = [
        ":iam_scanner_rules",
        ":scanner_test_utils",
    ],
)

py_library(
    name = "lien_scanner_rules",
    srcs = ["lien_scanner_rules.py"],
    deps = [":base_scanner_rules"],
)

py_test(
    name = "lien_scanner_rules_test",
    srcs = ["lien_scanner_rules_test.py"],
    python_version = "PY3",
    deps = [
        ":lien_scanner_rules",
        ":scanner_test_utils",
    ],
)

py_library(
    name = "location_scanner_rules",
    srcs = ["location_scanner_rules.py"],
    deps = [":base_scanner_rules"],
)

py_test(
    name = "location_scanner_rules_test",
    srcs = ["location_scanner_rules_test.py"],
    python_version = "PY3",
    deps = [
        ":location_scanner_rules",
        ":scanner_test_utils",
    ],
)

py_library(
    name = "log_sink_scanner_rules",
    srcs = ["log_sink_scanner_rules.py"],
    deps = [":base_scanner_rules"],
)

py_test(
    name = "log_sink_scanner_rules_test",
    srcs = ["log_sink_scanner_rules_test.py"],
    python_version = "PY3",
    deps = [
        ":log_sink_scanner_rules",
        ":scanner_test_utils",
    ],
)

py_library(
    name = "scanner_test_utils",
    testonly = 1,
    srcs = ["scanner_test_utils.py"],
    deps = ["//deploy/rule_generator:project_config"],
)

py_library(
    name = "resource_scanner_rules",
    srcs = ["resource_scanner_rules.py"],
    deps = [":base_scanner_rules"],
)

py_test(
    name = "resource_scanner_rules_test",
    srcs = ["resource_scanner_rules_test.py"],
    python_version = "PY3",
    deps = [
        ":resource_scanner_rules",
        ":scanner_test_utils",
    ],
)
