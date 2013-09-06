import std.stdio;
import std.random;
import std.string;
import std.array;
import std.math;
import std.conv;
import std.algorithm;

struct Cluster {
	real population;
	real sample;
	string stratum;
}

void set_sample(ref Cluster[] clusters, string stratum) {
	foreach (ref x; clusters) {
		if (x.stratum == stratum) {
			x.sample = x.population;
		}
	}
}

void select_clusters(ref Cluster[] clusters, string stratum, real stratum_sample, real cluster_size) {
	Random gen = Random(unpredictableSeed);
	int cnt = max(1, roundTo!int(trunc(stratum_sample / cluster_size)));
	real sample = stratum_sample / cnt;
	int i = 0;

	while (i < cnt) {
		real rand = uniform(0.0L, stratum_sample, gen);
		real sum = 0;

		foreach (ref x; clusters) {
			if (x.stratum == stratum) {
				sum += x.population;

				if (rand <= sum) {
					if (x.sample.isNaN) {
						x.sample = sample;
						i++;
					}

					break;
				}
			}
		}
	}
}

void main() {
	File t = File("in.txt", "r");
	t.readln;

	Cluster[] clusters;

	string s;
	while (t.readln(s)) {
		if (!strip(s).empty)
			clusters ~= Cluster(parse!real(s), real.nan, chomp(s)[1..$]);
	}

	write("Sample size = ");
	real coef = to!real(chomp(readln)) / reduce!((a, b) => a + b.population)(0.0L, clusters);
	write("Cluster size = ");
	real cluster_size = to!real(chomp(readln));

	struct Stratum {
		real population;
		int cnt;
	}

	Stratum[string] strata;

	foreach (ref x; clusters) {
		x.population *= coef;

		if (x.stratum !in strata)
			strata[x.stratum] = Stratum(0, 0);

		strata[x.stratum].population += x.population;
		strata[x.stratum].cnt++;
	}

	foreach (key, stratum; strata) {
		if (stratum.population / stratum.cnt >= cluster_size) {
			set_sample(clusters, key);
		} else {
			select_clusters(clusters, key, stratum.population, cluster_size);
		}
	}

	File w = File("out.txt", "w");

	w.writeln("Выборка ", reduce!((a, b) => a + (b.sample.isNaN ? 0 : 1))(0, clusters));
	foreach (x; clusters) {
		w.writeln(x.sample.isNaN ? 0 : x.sample);
	}
}