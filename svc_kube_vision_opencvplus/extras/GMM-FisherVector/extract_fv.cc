// Extract Fisher vectors
// Zexi Mao
// Jun. 2014

#include <cassert>
#include <fstream>
#include <iostream>
#include <iterator>
#include <sstream>
#include <vector>

#include "fisher.h"
#include "gmm.h"
#include "gzstream/gzstream.h"

using namespace std;

const int kGauss = 256;
const int kDes = 4;
const int kDim = 426;
const int kDimFull = 436;
const int kRange[4][2] = { {11, 40}, {41, 136}, {137, 244}, {245, 436} };
const int kDesDim[4] = {15, 48, 54, 96};

void SaveFv(vector<float*>&, string&);
void FinalNormalize(float*, int);

int main(int argc, const char **argv)
{
    // Check arguments.
    if (argc != 3) {
        fprintf(stderr, "Usage: %s save_name codebook_pca_list\n", argv[0]);
        exit(-1);
    }
    string tmp_name(argv[1]);
    string cb_pca_list_name(argv[2]);
    string save_name = tmp_name + ".gz";

    vector< vector<float*> > gmm_mean;
    vector< vector<float*> > gmm_var;
    vector< vector<float> > gmm_coef;
    vector< vector< vector<float> > > pca_proj;
    fstream cb_pca_list_file(cb_pca_list_name.c_str(), fstream::in);
    for (int i_des = 0; i_des < kDes; ++i_des) {
        string tmp_line;
        stringstream tmp_stream;
        getline(cb_pca_list_file, tmp_line);
        string codebook_name = tmp_line.substr(0, tmp_line.find(' '));
        string pca_proj_name = tmp_line.substr(tmp_line.find(' ')+1);
        
        /*****************************
         ** Start reading codebook. **
         *****************************/
        vector<float*> this_gmm_mean;
        vector<float*> this_gmm_var;
        vector<float> this_gmm_coef(kGauss);
        fstream codebook_file(codebook_name.c_str(), fstream::in);

        // Check validity of the codebook files.
        int in_gauss, in_dim1, in_dim2;
        getline(codebook_file, tmp_line);
        tmp_stream.clear();
        tmp_stream.str(tmp_line);
        tmp_stream >> in_dim1 >> in_gauss;
        assert(in_dim1 == kDesDim[i_des]);
        assert(in_gauss == kGauss);
#ifdef DEBUG
        cout << "Codebook validated " << i_des << '!' << endl;
#endif

        // Read out each GMM mean.
        getline(codebook_file, tmp_line);
        tmp_stream.clear();
        tmp_stream.str(tmp_line);
        for (int j_gauss = 0; j_gauss < kGauss; ++j_gauss) {
            float *this_mean = new float[in_dim1];
            for (int k_dim = 0; k_dim < in_dim1; ++k_dim)
                tmp_stream >> this_mean[k_dim];
            this_gmm_mean.push_back(this_mean);
        }

        // Read out each GMM variance.
        getline(codebook_file, tmp_line);
        getline(codebook_file, tmp_line);
        tmp_stream.clear();
        tmp_stream.str(tmp_line);
        for (int j_gauss = 0; j_gauss < kGauss; ++j_gauss) {
            float *this_var = new float[in_dim1];
            for (int k_dim = 0; k_dim < in_dim1; ++k_dim)
                tmp_stream >> this_var[k_dim];
            this_gmm_var.push_back(this_var);
        }

        // Read out each GMM weight.
        getline(codebook_file, tmp_line);
        getline(codebook_file, tmp_line);
        tmp_stream.clear();
        tmp_stream.str(tmp_line);
        for (int j_gauss = 0; j_gauss < kGauss; ++j_gauss)
            tmp_stream >> this_gmm_coef[j_gauss];

        gmm_mean.push_back(this_gmm_mean);
        gmm_var.push_back(this_gmm_var);
        gmm_coef.push_back(this_gmm_coef);

        /*****************************
         Start reading PCA projection.
         *****************************/
        vector< vector<float> > this_pca_proj;
        fstream pca_proj_file(pca_proj_name.c_str(), fstream::in);

        // Check the validity of the PCA projection files.
        getline(pca_proj_file, tmp_line);
        tmp_stream.clear();
        tmp_stream.str(tmp_line);
        tmp_stream >> in_dim1 >> in_dim2;
        assert(in_dim1 == kDesDim[i_des]);
        assert(in_dim2 == kDesDim[i_des] * 2);
#ifdef DEBUG
        cout << "PCA projection validated " << i_des << '!' << endl;
#endif

        // Read out each PCA projection.
        getline(pca_proj_file, tmp_line);
        tmp_stream.clear();
        tmp_stream.str(tmp_line);
        for (int j_dim = 0; j_dim < in_dim1; ++j_dim) {
            vector<float> pca_proj_line(in_dim2);
            this_pca_proj.push_back(pca_proj_line);
        }
        for (int k_dim = 0; k_dim < in_dim2; ++k_dim) {
            for (int j_dim = 0; j_dim < in_dim1; ++j_dim)
                tmp_stream >> this_pca_proj[j_dim][k_dim];
        }
        pca_proj.push_back(this_pca_proj);
    }

    // Initialize the Fisher vectors.
    vector< fisher<float>* > fishers;
    for (int i_des = 0; i_des < kDes; ++i_des) {
        // Prepare a GMM with the codebook.
        gaussian_mixture<float> *this_gmm_proc = new gaussian_mixture<float>(kGauss, kDesDim[i_des]);
        this_gmm_proc->set(gmm_mean[i_des], gmm_var[i_des], gmm_coef[i_des]);

        // Construct a struct with default parameter values.
        fisher_param fisher_encoder_params;
        fisher<float> *this_fisher = new fisher<float>(fisher_encoder_params);

        // Initialize the encoder with the GMM codebook.
        this_fisher->set_model(*this_gmm_proc);

        fishers.push_back(this_fisher);
    }

    /*****************************
      Start reading raw features.
     *****************************/
    string traj_line;
    stringstream traj_stream;
    while (getline(cin, traj_line)) {
#ifndef DEBUG
        // Send the exact raw features to the standard output.
        cout << traj_line << endl;
#endif

        traj_stream.clear();
        traj_stream.str(traj_line);
        float *sample_point = new float[kDimFull];
        for (int i_float = 0; i_float < kDimFull; ++i_float)
            traj_stream >> sample_point[i_float];


        for (int i_des = 0; i_des < kDes; ++i_des) {
            float *sub_sample = sample_point;
            sub_sample += (kRange[i_des][0] - 1);

            // Perform RootSIFT normalization, only do it for hog, hof, mbh, (don't do it for traj).
            if (i_des >= 1) {
                float sum = 0.0;
                for (int j_dim = 0; j_dim < 2*kDesDim[i_des]; ++j_dim)
                    sum += sub_sample[j_dim];
                for (int j_dim = 0; j_dim < 2*kDesDim[i_des]; ++j_dim)
                    sub_sample[j_dim] = sqrt(sub_sample[j_dim] / sum);
            }

            // Perform PCA and feed the shortened features into the Fisher vectors.
            float *sample_out = new float[kDesDim[i_des]](); // This includes the initialization to 0,
            for (int j_dim = 0; j_dim < kDesDim[i_des]; ++j_dim) {
                for (int k_dim = 0; k_dim < kDesDim[i_des]*2; ++k_dim)
                    sample_out[j_dim] += sub_sample[k_dim] * pca_proj[i_des][j_dim][k_dim];
            }
            fishers[i_des]->AddOne(sample_out);
            delete[] sample_out;
        }
        delete[] sample_point;
    }

#ifdef DEBUG
    cout << "Reading finished!" << endl;
#endif

    vector<float*> fisher_vectors;
    for (int i_des = 0; i_des < kDes; ++i_des) {
        // Compute the Fisher vectors.
        fishers[i_des]->Compute();
        fishers[i_des]->alpha_and_lp_normalization();
        float *this_fv = fishers[i_des]->get_fv();
        fisher_vectors.push_back(this_fv);
    }


    // Final Normalization
    for (int i_des = 0; i_des < kDes; ++i_des) {
        FinalNormalize(fisher_vectors[i_des], 2*kGauss*kDesDim[i_des]);
    }

    // Output the Fisher vectors to gzipped files.
    SaveFv(fisher_vectors, save_name);

    // Clean up.
    for (vector<float*>::iterator fv_it = fisher_vectors.begin(); fv_it != fisher_vectors.end(); ++fv_it)
        delete[] (*fv_it);
    for (vector< vector<float*> >::iterator gmm_mean_it = gmm_mean.begin(); gmm_mean_it != gmm_mean.end(); ++gmm_mean_it) {
        for (vector<float*>::iterator this_mean_it = (*gmm_mean_it).begin(); this_mean_it != (*gmm_mean_it).end(); ++this_mean_it)
            delete[] (*this_mean_it);
    }
    for (vector< vector<float*> >::iterator gmm_var_it = gmm_var.begin(); gmm_var_it != gmm_var.end(); ++gmm_var_it) {
        for (vector<float*>::iterator this_var_it = (*gmm_var_it).begin(); this_var_it != (*gmm_var_it).end(); ++this_var_it)
            delete[] (*this_var_it);
    }
}


void SaveFv(vector<float*>& this_fvs, string& save_name)
{
    ogzstream save_file(save_name.c_str());
    int count = 0;

    for (int i_des = 0; i_des < kDes; ++i_des) {
        for (int j_dim = 0; j_dim < 2*kGauss*kDesDim[i_des]; ++j_dim)
            save_file << ++count << ':' << this_fvs[i_des][j_dim] << ' ';
    }
    save_file.close();
}


void FinalNormalize(float *this_fv, int n_dim)
{
    // L2 normalization on whole code.
    float norm_factor = 0.0;
    for (int i_dim = n_dim; i_dim--;)
        norm_factor += this_fv[i_dim] * this_fv[i_dim];
    if (norm_factor > 0.0) {
#ifdef DEBUG
        cout << "Inside normalization1" << endl;
#endif
        norm_factor = sqrt(norm_factor);
        for (int i_dim = n_dim; i_dim--;)
            this_fv[i_dim] /= norm_factor;
    }

    // Apply Hellinger kernel map.
    for (int i_dim = n_dim; i_dim--;) {
        if (this_fv[i_dim] < 0.0)
            this_fv[i_dim] = - sqrt(-this_fv[i_dim]);
        else
            this_fv[i_dim] = sqrt(this_fv[i_dim]);
    }

    // L2 post-normalization on whole code and divide by two to make the whole
    // vector L2-normalized.
    float post_factor = 0.0;
    for (int i_dim = n_dim; i_dim--;)
        post_factor += this_fv[i_dim] * this_fv[i_dim];
    if (post_factor > 0.0) {
#ifdef DEBUG
        cout << "Inside normalization2" << endl;
#endif
        post_factor = sqrt(post_factor);
        post_factor *= 2.0;
        for (int i_dim = n_dim; i_dim--;)
            this_fv[i_dim] /= post_factor;
    }
}
